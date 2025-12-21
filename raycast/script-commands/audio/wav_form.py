#!/Users/jeguan/tools/anaconda/bin/python3

# Raycast Script Command Template
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Audio Waveform
# @raycast.mode fullOutput
# @raycast.packageName Audio Tools
#
# Optional parameters:
# @raycast.icon 🔊
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
#
# @raycast.argument1 {
#     "type": "dropdown",
#     "placeholder": "Input Source",
#     "default": "picker",
#     "data": [
#         {"title": "File Picker (Dialog)", "value": "picker"},
#         {"title": "Finder Selection", "value": "selection"}
#     ]
#
# Documentation:
# @raycast.description Generate waveform or comparison. Select 1 or 2 files.
# @raycast.author JeffreyGuan
# @raycast.authorURL https://github.com/double12gzh

# ==============================
# Check dependencies
# ==============================
import sys
import os
import argparse
import subprocess

try:
    import matplotlib
except ImportError:
    print("❌ Error: Missing matplotlib module")
    print("Please run:")
    print("  pip install matplotlib scipy numpy")
    sys.exit(1)

# ==============================
# Set GUI backend
# ==============================
if "matplotlib.backends" not in sys.modules:
    if sys.platform == "darwin":
        try:
            matplotlib.use("MacOSX")
        except Exception:
            matplotlib.use("TkAgg")
    else:
        matplotlib.use("TkAgg")

try:
    import matplotlib.pyplot as plt
    from scipy.io import wavfile
    import numpy as np
except ImportError as e:
    print(f"❌ Error: Missing dependencies: {e}")
    sys.exit(1)


def compute_audio_stats(original_data, normalized_data, sample_rate):
    """Compute stats from both original and normalized data."""
    n_samples = len(original_data)
    duration = n_samples / sample_rate

    rms_original = np.sqrt(np.mean(original_data.astype(np.float32) ** 2))
    rms_normalized = np.sqrt(np.mean(normalized_data.astype(np.float32) ** 2))

    y = normalized_data
    y_sign = np.sign(y)
    y_sign_nozero = y_sign.copy()
    for i in range(1, len(y_sign_nozero)):
        if y_sign_nozero[i] == 0:
            y_sign_nozero[i] = y_sign_nozero[i - 1]
    zero_crossings = np.sum(y_sign_nozero[1:] != y_sign_nozero[:-1])

    return {
        "sample_rate": sample_rate,
        "duration": duration,
        "n_samples": n_samples,
        "rms_original": rms_original,
        "rms_normalized": rms_normalized,
        "zero_crossings": zero_crossings,
    }


def load_and_normalize(wav_path):
    """Load audio and return time, normalized waveform, and stats."""
    if not os.path.exists(wav_path):
        raise FileNotFoundError(f"Audio file not found: {wav_path}")
    try:
        sr, data = wavfile.read(wav_path, mmap=True)
    except ValueError as e:
        print(f"❌ Error reading {os.path.basename(wav_path)}: {e}")
        sys.exit(1)

    if data.ndim > 1:
        data = data[:, 0]  # Use left channel

    current_max = np.abs(data).max()
    y_norm = data / current_max if current_max > 0 else data

    stats = compute_audio_stats(data, y_norm, sr)
    x = np.linspace(0, stats["duration"], len(data), dtype=np.float32)
    return x, y_norm, stats


def format_info_text(stats, label=""):
    prefix = f"{label}\n" if label else ""
    return (
        f"{prefix}"
        f"Sample Rate: {stats['sample_rate']} Hz\n"
        f"Duration: {stats['duration']:.3f} s\n"
        f"Samples: {stats['n_samples']}\n"
        f"RMS (orig): {stats['rms_original']:.4f}\n"
        f"RMS (norm): {stats['rms_normalized']:.4f}"
    )


def plot_single_waveform(audio_path, output, show=True, save=True):
    print(f"📊 Generating waveform for: {os.path.basename(audio_path)}")
    x, y, stats = load_and_normalize(audio_path)

    fig, ax = plt.subplots(figsize=(10, 4), dpi=100)
    ax.plot(x, y, color="steelblue", linewidth=0.6)
    ax.set_xlabel("Time (s)")
    ax.set_ylabel("Amplitude")
    ax.set_title(f"Waveform: {os.path.basename(audio_path)}")
    ax.grid(True, alpha=0.3, linestyle="--")

    info_text = format_info_text(stats)
    ax.text(
        0.02,
        0.95,
        info_text,
        transform=ax.transAxes,
        fontsize=9,
        verticalalignment="top",
        bbox=dict(boxstyle="round", facecolor="white", alpha=0.9),
        family="monospace",
    )

    fig.tight_layout()
    try:
        if save:
            fig.savefig(output, dpi=120)
            print(f"✅ Saved: {output}")
        if show:
            plt.show()  # Show the plot window
    except Exception as e:
        print(f"❌ Error saving/showing plot: {e}")


def plot_dual_waveforms(audio1, audio2, output, show=True, save=True):
    print(
        f"📊 Generating comparison:\n"
        f"   1: {os.path.basename(audio1)}\n"
        f"   2: {os.path.basename(audio2)}"
    )
    x1, y1, stats1 = load_and_normalize(audio1)
    x2, y2, stats2 = load_and_normalize(audio2)

    fig, axs = plt.subplots(3, 1, figsize=(10, 10), dpi=100)

    # Audio 1
    axs[0].plot(x1, y1, color="steelblue", linewidth=0.6)
    axs[0].set_title(f"1: {os.path.basename(audio1)}")
    axs[0].grid(True, alpha=0.3)
    axs[0].text(
        0.01,
        0.95,
        format_info_text(stats1),
        transform=axs[0].transAxes,
        fontsize=8,
        va="top",
        bbox=dict(facecolor="white", alpha=0.8),
    )

    # Audio 2
    axs[1].plot(x2, y2, color="darkorange", linewidth=0.6)
    axs[1].set_title(f"2: {os.path.basename(audio2)}")
    axs[1].grid(True, alpha=0.3)
    axs[1].text(
        0.01,
        0.95,
        format_info_text(stats2),
        transform=axs[1].transAxes,
        fontsize=8,
        va="top",
        bbox=dict(facecolor="white", alpha=0.8),
    )

    # Overlay
    axs[2].plot(x1, y1, color="steelblue", alpha=0.7, label="Audio 1", linewidth=0.8)
    axs[2].plot(x2, y2, color="darkorange", alpha=0.7, label="Audio 2", linewidth=0.8)
    axs[2].set_title("Overlay Comparison")
    axs[2].legend(loc="upper right")
    axs[2].grid(True, alpha=0.3)

    fig.tight_layout()
    try:
        if save:
            fig.savefig(output, dpi=120)
            print(f"✅ Saved: {output}")
        if show:
            plt.show()
    except Exception as e:
        print(f"❌ Error saving/showing plot: {e}")


def get_finder_selection():
    """Get currently selected files in Finder via AppleScript."""
    script = """
    tell application "Finder"
        set theSelection to selection
        if theSelection is {} then return ""
        set fileList to {}
        repeat with aFile in theSelection
            set end of fileList to POSIX path of (aFile as alias)
        end repeat
        set AppleScript's text item delimiters to "\n"
        return fileList as string
    end tell
    """
    try:
        result = subprocess.run(
            ["osascript", "-e", script], capture_output=True, text=True
        )
        if result.returncode != 0 or not result.stdout.strip():
            return []
        return result.stdout.strip().split("\n")
    except Exception as e:
        print(f"❌ Error getting Finder selection: {e}")
        return []


def open_file_picker(prompt="Select Audio Files"):
    """Open a file picker that allows multiple selections."""
    script = f"""
    try
        set theFiles to choose file with prompt "{prompt}" of type {{"wav"}} with multiple selections allowed
        set fileList to {{}}
        repeat with aFile in theFiles
            set end of fileList to POSIX path of aFile
        end repeat
        set AppleScript's text item delimiters to "\n"
        return fileList as string
    on error
        return ""
    end try
    """
    try:
        result = subprocess.run(
            ["osascript", "-e", script], capture_output=True, text=True
        )
        if result.returncode != 0 or not result.stdout.strip():
            return []
        return result.stdout.strip().split("\n")
    except Exception as e:
        print(f"❌ Error opening file picker: {e}")
        return []


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Audio Waveform Generator")

    # Raycast arguments
    parser.add_argument(
        "source", nargs="?", default="picker", help="Input source (picker/selection)"
    )
    parser.add_argument("files", nargs="*", help="Audio files")

    parser.add_argument("-o", "--output", default=None, help="Output file path")
    parser.add_argument(
        "--no_show", action="store_true", help="Do not show the plot window"
    )
    parser.add_argument(
        "-s", "--save", action="store_true", help="Save the plot to file"
    )
    return parser.parse_args()


def resolve_source_and_files(args):
    """Determine the source mode and initial files from arguments."""
    source_mode = args.source
    initial_files = []

    if source_mode and source_mode.lower().endswith(".wav"):
        initial_files.append(source_mode)
        source_mode = "manual"  # Treat as manual file input
    elif source_mode not in ["picker", "selection"]:
        # Maybe it's a file path that doesn't end in wav? Or invalid arg.
        # Let's assume it's manual if it looks like a path
        if os.path.exists(source_mode):
            initial_files.append(source_mode)
            source_mode = "manual"

    if args.files:
        initial_files.extend(args.files)

    return source_mode, initial_files


def fetch_files(source_mode, initial_files):
    """Fetch files based on source mode and initial files."""
    if initial_files:
        return initial_files

    selected_files = []
    if source_mode == "selection":
        print("🔍 Checking Finder selection...")
        selected_files = get_finder_selection()
        if not selected_files:
            print("⚠️ No files selected in Finder. Switching to File Picker.")
            selected_files = open_file_picker()
    elif source_mode == "picker":
        selected_files = open_file_picker()

    return selected_files


def filter_valid_files(files):
    """Filter for valid .wav files."""
    if not files:
        return []
    return [f for f in files if os.path.exists(f) and f.lower().endswith(".wav")]


def process_files(valid_files, output_path, show=True, save=True):
    """Generate waveform plots for valid files."""
    if len(valid_files) == 0:
        print("❌ No valid .wav files found.")
        sys.exit(1)

    if len(valid_files) == 1:
        plot_single_waveform(valid_files[0], output_path, show=show, save=save)
    elif len(valid_files) == 2:
        plot_dual_waveforms(
            valid_files[0], valid_files[1], output_path, show=show, save=save
        )
    else:
        print(
            f"⚠️ Selected {len(valid_files)} files. Taking the first 2 for comparison."
        )
        plot_dual_waveforms(
            valid_files[0], valid_files[1], output_path, show=show, save=save
        )


def generate_default_output_filename(files):
    """Generate a default output filename based on input files."""
    if not files:
        return "waveform.png"

    base_names = [os.path.splitext(os.path.basename(f))[0] for f in files[:2]]
    return "_".join(base_names) + ".png"


def main():
    args = parse_arguments()
    source_mode, initial_files = resolve_source_and_files(args)

    selected_files = fetch_files(source_mode, initial_files)

    if not selected_files:
        print("❌ No files selected.")
        sys.exit(0)

    valid_files = filter_valid_files(selected_files)

    output_path = args.output
    if output_path is None:
        output_path = generate_default_output_filename(valid_files)

    process_files(valid_files, output_path, show=not args.no_show, save=args.save)


if __name__ == "__main__":
    main()
