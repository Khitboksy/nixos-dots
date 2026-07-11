# ============================================================================
# LIVE USB REPARTITION INSTRUCTIONS
# Read this file from a live USB environment BEFORE touching anything.
# ============================================================================
#
# GOAL:
#   Shrink /home (nvme0n1p3, currently 731 GiB) by ~18 GiB.
#   Create nvme0n1p4 as a 16 GiB swap partition in the freed space.
#   Replace the PARTUUID placeholder below with the real one.
#
# CURRENT DISK LAYOUT (nvme0n1 — 931.5 GiB / 1 TB):
#   nvme0n1p1  500 MiB  vfat   /boot
#   nvme0n1p2  200 GiB  ext4   /  (root + /nix/store)
#   nvme0n1p3  731 GiB  ext4   /home   ← we're shrinking this
#   [free space]  ← new nvme0n1p4 swap goes here
#
# WHAT YOU DO IN THE LIVE ENVIRONMENT:
#   Commands are below. Run them one at a time. Read the output of each.
#
# ===== PREREQUISITES =====
# You need: a Linux live USB (any distro works — Ubuntu, NixOS, Arch, etc.)
# Boot from it, open a terminal.
#
# ===== STEP 1: Identify the drives =====
# Run this to confirm you're looking at the right drive:
#
#   lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS
#
# You should see both NVMe drives. Confirm nvme0n1 matches the layout above.
# If the drive letters are different (e.g., sda, nvme1n1), adjust all commands.
#
# ===== STEP 2: Check the filesystem =====
# This must succeed without errors before you shrink:
#
#   sudo e2fsck -f /dev/nvme0n1p3
#
# OK output looks like:
#   /dev/nvme0n1p3: #####/##### files (####/#### blocks)
#   /dev/nvme0n1p3: #####/#### files (##.#% non-contiguous), ########/######## blocks
#
# If it says "has errors" — STOP. Run: sudo e2fsck -f -y /dev/nvme0n1p3
# If it still fails, your filesystem might have real damage.
#
# ===== STEP 3: Shrink the filesystem =====
# Shrink the ext4 filesystem inside the partition to 708 GiB.
# This makes the filesystem smaller. The partition still takes 731 GiB.
#
#   sudo resize2fs /dev/nvme0n1p3 708G
#
# ✓ Expected output: "The filesystem on /dev/nvme0n1p3 is now ##### (4k) blocks long."
# ✗ If it says "Nothing to do!" — try a smaller number like 705G.
# ✗ If it says "mount" or "busy" — you forgot to boot from a live USB.
#
# ===== STEP 4: Resize the partition =====
# Now shrink the partition to match the filesystem.
#
#   sudo parted /dev/nvme0n1
#
# Inside parted:
#
#   (parted) unit MiB
#   (parted) print free
#
# You'll see something like:
#   Number  Start       End          Size         File system  Name     Flags
#   1       1.00MiB     501MiB       500MiB       fat16        primary  boot
#   2       501MiB      205301MiB    204800MiB    ext4         primary
#   3       205301MiB   953XXXMiB    748XXXMiB    ext4         primary
#          953XXXMiB   954XXXMiB    18500MiB     Free Space
#
# Note the "*MiB" value in the "End" column of partition 3.
# We'll call this CURRENT_END (e.g., 953000).
#
# Calculate: NEW_END = CURRENT_END - 18432
# (18432 MiB = 18 GiB — we shrink by 18 GiB to free room for 16 GiB swap)
#
#   (parted) resizepart 3 NEW_END
#   (parted) mkpart primary linux-swap (NEW_END + 2)MiB 100%
#
# For example if CURRENT_END is 953000:
#   (parted) resizepart 3 934568
#   (parted) mkpart primary linux-swap 934570MiB 100%
#
#   (parted) print free
#
# Verify: partition 3 is now smaller, partition 4 (16 GiB, linux-swap) exists.
#
#   (parted) quit
#
# If parted is not available: try `sudo sgdisk -n 0:0:+16G -t 0:8200 /dev/nvme0n1`
#
# ===== STEP 5: Get the PARTUUID =====
# This is what goes into the NixOS config. PARTUUID never changes — it's in
# the GPT partition table itself, not in the swap filesystem.
#
#   sudo blkid /dev/nvme0n1p4
#
# Output looks like:
#   /dev/nvme0n1p4: PARTUUID="98a7b3c2-04d1-4f6e-8a9b-1c2d3e4f5a6b"
#
# Copy that PARTUUID string (WITH quotes) — you'll paste it below.
#
# ===== STEP 6: Done in live environment =====
# Reboot back into NixOS. Then:
#
#   1. Edit this file: replace "REPLACE-WITH-YOUR-PARTUUID" with the
#      actual PARTUUID from step 5 (keep the quotes).
#
#   2. Run: sudo nixos-rebuild switch --flake ~/builds#helios
#
#   3. Check it worked: swapon --show   (should show /dev/zram0, /dev/dm-X, /swapfile)
#                       free -h          (Swap total should be ~48 GiB shown)
#                       zramctl          (shows compression ratio)
#
# ============================================================================

{
  fileSystems = {

    "/" = {
      device = "/dev/disk/by-uuid/d8549c68-ef86-425f-8b9b-5125e8973b77";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/3e0c8f46-7ef6-4e81-a286-b709e2011c25";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9861-91BE";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/mnt/nix-data" = {
      device = "/dev/disk/by-uuid/69f8977c-153f-40b5-9eea-3066e071bf1c";
      fsType = "ext4";
    };

    "/mnt/nix-data/media/music" = {
      device = "100.119.96.108:/srv/music";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "noatime"
      ];
    };

  };

  # === SWAP STRATEGY ===
  # Tier 1 — ZRAM (in-memory compressed swap, configured in default.nix)  → priority 100
  #   This is the only swap active right now. Enough for normal use.
  #
  # To re-enable disk swap later:
  #   1. Create nvme0n1p4 from a live USB (see instructions at top of this file)
  #   2. Replace the PARTUUID placeholder below and uncomment the block
  #   3. Optionally uncomment the /swapfile entry for hibernation
  #   4. sudo nixos-rebuild switch

  swapDevices = [

    # Tier 2 — Encrypted swap partition (16 GiB on nvme0n1p4)
    #
    # ⚠️  BEFORE THIS WORKS: you must create nvme0n1p4 from a live USB.
    #    See the giant comment block at the top of this file for the procedure.
    #
    # After creation, get the PARTUUID with: sudo blkid /dev/nvme0n1p4
    # Then paste it here. Example:
    #   device = "/dev/disk/by-partuuid/98a7b3c2-04d1-4f6e-8a9b-1c2d3e4f5a6b";
    #
    # Random encryption = swap is scrambled with a fresh random key every boot.
    # Prevents sensitive data leaking to disk. Incompatible with hibernation
    # (but Tier 3 handles that separately).
    # {
    #   device = "/dev/disk/by-partuuid/REPLACE-WITH-YOUR-PARTUUID";
    #   randomEncryption.enable = true;
    #   priority = 5;
    # }

    # Tier 3 — Unencrypted swap file for hibernation only
    #
    # Priority 0 = kernel never uses this during normal operation. ZRAM (100)
    # and the encrypted partition (5) fill first. This file sits untouched
    # until you run: systemctl hibernate
    #
    # 32768 MiB = 32 GiB (must be >= total RAM for hibernation to work)
    #
    # AFTER first rebuild + reboot, one extra step is needed:
    #   sudo filefrag -v /swapfile | awk 'NR==4 {print $4}' | cut -d. -f1
    # This gives you the resume_offset. Put it in default.nix (see there).
    # {
    #   device = "/swapfile";
    #   size = 32768;
    #   priority = 0;
    # }
  ];

  #fileSystems."/mnt/oldnix" = {
  #  device = "/dev/disk/by-uuid/fb75032f-14f7-41c9-b79a-27372fdd1bd4";
  #  fsType = "ext4";
  #};
}
