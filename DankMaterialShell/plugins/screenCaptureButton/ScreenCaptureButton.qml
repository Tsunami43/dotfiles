import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    pillClickAction: (x, y, width, section, screen) => {
        Quickshell.execDetached(["dms", "ipc", "call", "screenCaptureToolbar", "toggle"])
    }

    horizontalBarPill: Component {
        DankIcon {
            name: "photo_camera"
            color: Theme.primary
            size: Theme.iconSize - 6
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "photo_camera"
            color: Theme.primary
            size: Theme.iconSize - 6
        }
    }
}
