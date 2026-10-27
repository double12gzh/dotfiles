# find out which distribution we are running on
if [[ "$OSTYPE" == darwin* ]]; then
    _distro="macos"
elif [[ -f /etc/os-release ]]; then
    _distro=$(awk -F'=' '/^ID=/ { gsub(/"/, "", $2); print tolower($2) }' /etc/os-release)
else
    echo "Unsupported distribution"
fi

# set an icon based on the distro
# make sure your font is compatible with https://github.com/lukas-w/font-logos
case $_distro in
    *alpine*)                ICON="" ;;
    *aosc*)                  ICON="" ;;
    *arch*)                  ICON="" ;;
    *centos*)                ICON="" ;;
    *coreos*)                ICON="" ;;
    *debian*)                ICON="" ;;
    *devuan*)                ICON="" ;;
    *elementary*)            ICON="" ;;
    *fedora*)                ICON="" ;;
    *gentoo*)                ICON="" ;;
    *kali*)                  ICON="ﴣ" ;;
    *linuxmint*)             ICON="" ;;
    *macos*)                 ICON="🍏" ;;
    *mageia*)                ICON="" ;;
    *manjaro*)               ICON="" ;;
    *nixos*)                 ICON="" ;;
    *opensuse*|*tumbleweed*) ICON="" ;;
    *raspbian*)              ICON="" ;;
    *rhel*)                  ICON="" ;;
    *sabayon*)               ICON="" ;;
    *slackware*)             ICON="" ;;
    *ubuntu*)                ICON="" ;;
    *void*)                  ICON="" ;;
    *)                       ICON="" ;;
esac

export STARSHIP_DISTRO="$ICON"
