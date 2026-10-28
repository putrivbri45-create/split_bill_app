import os
import shutil
from PIL import Image

def generate_icons():
    source_path = os.path.join("stitch_patungan_split_bill_app_ui", "logo_patungan", "screen.png")
    if not os.path.exists(source_path):
        print(f"Source image not found: {source_path}")
        return

    # 1. Copy source to assets/images/app_logo.png
    assets_dir = os.path.join("assets", "images")
    os.makedirs(assets_dir, exist_ok=True)
    target_asset = os.path.join(assets_dir, "app_logo.png")
    shutil.copy2(source_path, target_asset)
    print(f"Copied to {target_asset}")

    # Also save a 512x512 playstore icon if needed
    playstore_icon = os.path.join(assets_dir, "playstore_icon.png")
    img = Image.open(source_path).convert("RGBA")
    img.resize((512, 512), Image.Resampling.LANCZOS).save(playstore_icon)
    print(f"Saved {playstore_icon}")

    # 2. Android mipmap dimensions
    mipmap_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    res_dir = os.path.join("android", "app", "src", "main", "res")
    for folder, size in mipmap_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save standard ic_launcher.png
        launcher_path = os.path.join(folder_path, "ic_launcher.png")
        resized.save(launcher_path, format="PNG")
        print(f"Generated {launcher_path} ({size}x{size})")

        # Save round ic_launcher_round.png
        round_path = os.path.join(folder_path, "ic_launcher_round.png")
        resized.save(round_path, format="PNG")
        print(f"Generated {round_path} ({size}x{size})")

    # 3. Check web icons as well if web/icons exists
    web_icons_dir = os.path.join("web", "icons")
    if os.path.exists(web_icons_dir):
        img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-192.png"))
        img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-512.png"))
        img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-192.png"))
        img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-512.png"))
        favicon_path = os.path.join("web", "favicon.png")
        img.resize((32, 32), Image.Resampling.LANCZOS).save(favicon_path)
        print("Updated web icons & favicon as well.")

    print("App icon generation completed successfully!")

if __name__ == "__main__":
    generate_icons()
