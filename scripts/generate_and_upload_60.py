#!/usr/bin/env python3
"""Generate 60 poster images and upload them to Google Drive.

Required env vars:
- OPENAI_API_KEY
- GOOGLE_SERVICE_ACCOUNT_JSON (path)
- GOOGLE_DRIVE_FOLDER_ID
Optional:
- OPENAI_IMAGE_MODEL (default: gpt-image-1)
- OUTPUT_DIR (default: generated)
"""
from __future__ import annotations

import base64
import json
import os
import pathlib
import time
from dataclasses import dataclass

from openai import OpenAI
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

STYLE_PROMPTS = [
    "Japandi x Zen minimalist wall art, textured washi paper, soft neutral palette, museum-quality composition",
    "Wabi-sabi monochrome ink composition with modern kanji balance, high contrast black and white",
    "1980s Japanese urban leisure poster vibe, geometric shadows, quiet dusk, elegant modern finish",
    "Showa retro kissaten atmosphere, subtle nostalgia, refined poster composition, no logos",
    "Sumo-inspired dynamic silhouette with minimalist negative space, contemporary gallery style",
    "Ramen alley mood scene, warm light, clean graphic structure, printable wall art aesthetic",
]

@dataclass
class Config:
    openai_api_key: str
    service_account_json: str
    drive_folder_id: str
    model: str = "gpt-image-1"
    output_dir: str = "generated"


def load_config() -> Config:
    return Config(
        openai_api_key=os.environ["OPENAI_API_KEY"],
        service_account_json=os.environ["GOOGLE_SERVICE_ACCOUNT_JSON"],
        drive_folder_id=os.environ["GOOGLE_DRIVE_FOLDER_ID"],
        model=os.getenv("OPENAI_IMAGE_MODEL", "gpt-image-1"),
        output_dir=os.getenv("OUTPUT_DIR", "generated"),
    )


def drive_client(service_account_json: str):
    scopes = ["https://www.googleapis.com/auth/drive.file"]
    creds = service_account.Credentials.from_service_account_file(service_account_json, scopes=scopes)
    return build("drive", "v3", credentials=creds)


def generate_image(client: OpenAI, model: str, prompt: str) -> bytes:
    resp = client.images.generate(model=model, prompt=prompt, size="1536x1024")
    b64 = resp.data[0].b64_json
    return base64.b64decode(b64)


def upload_file(drive, folder_id: str, file_path: pathlib.Path) -> str:
    metadata = {"name": file_path.name, "parents": [folder_id]}
    media = MediaFileUpload(str(file_path), mimetype="image/png")
    f = drive.files().create(body=metadata, media_body=media, fields="id, webViewLink").execute()
    return f.get("webViewLink", "")


def main() -> None:
    cfg = load_config()
    out_dir = pathlib.Path(cfg.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    openai_client = OpenAI(api_key=cfg.openai_api_key)
    drive = drive_client(cfg.service_account_json)

    manifest = []
    for i in range(60):
        prompt = STYLE_PROMPTS[i % len(STYLE_PROMPTS)] + ", ultra-detailed printable poster, no text artifacts, no logos"
        filename = f"poster_{i+1:02d}.png"
        filepath = out_dir / filename

        image_bytes = generate_image(openai_client, cfg.model, prompt)
        filepath.write_bytes(image_bytes)
        link = upload_file(drive, cfg.drive_folder_id, filepath)

        manifest.append({"index": i + 1, "prompt": prompt, "file": str(filepath), "drive_link": link})
        time.sleep(0.5)

    (out_dir / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Generated and uploaded {len(manifest)} images. Manifest: {out_dir / 'manifest.json'}")


if __name__ == "__main__":
    main()
