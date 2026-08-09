from PIL import Image
import os
import shutil

src_path = r"c:\Users\ATS-L15\Desktop\Montra\montra\assets\images\compressed-logo.webp"
res_dir = r"c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res"

# Load image and save as png
try:
    img = Image.open(src_path)
    img = img.convert("RGBA")
    
    # Save to drawable
    drawable_path = os.path.join(res_dir, "drawable", "app_logo.png")
    img.save(drawable_path, "PNG")
    print(f"Saved to {drawable_path}")
    
    # Replace ic_launcher in all mipmap folders
    for folder in os.listdir(res_dir):
        if folder.startswith("mipmap-"):
            mipmap_dir = os.path.join(res_dir, folder)
            launcher_path = os.path.join(mipmap_dir, "ic_launcher.png")
            if os.path.exists(launcher_path):
                img.save(launcher_path, "PNG")
            
            # also replace round icons if they exist
            launcher_round_path = os.path.join(mipmap_dir, "ic_launcher_round.png")
            if os.path.exists(launcher_round_path):
                img.save(launcher_round_path, "PNG")
                
    print("All ic_launcher.png files have been replaced with the compressed logo.")
except Exception as e:
    print(f"Error: {e}")
