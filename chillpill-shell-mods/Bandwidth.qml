import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string rxTotal: "..."
    property string txTotal: "..."

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    Process {
        id: bwProc
        command: ["sh", "-c", "awk 'NR>2 && !/^ *lo/ && $2>0 {print $2, $10; exit}' /proc/net/dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parts = this.text.trim().split(/\s+/)
                    if (parts.length < 2) return
                    root.rxTotal = formatBytes(parseInt(parts[0]))
                    root.txTotal = formatBytes(parseInt(parts[1]))
                } catch (e) {
                    console.log("bandwidth parse error:", e)
                }
            }
        }
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + " MB"
        return (bytes / 1073741824).toFixed(1) + " GB"
    }

    Timer {
        interval: Config.bandwidthRefreshInterval
        running: visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            bwProc.running = false
            bwProc.running = true
        }
    }

    Column {
        id: col
        spacing: 2

        Text {
            text: "↓ " + root.rxTotal
            color: Theme.fg
            font { family: Theme.fontFamily; pixelSize: 10; weight: 600 }
        }

        Text {
            text: "↑ " + root.txTotal
            color: Theme.fg
            opacity: 0.6
            font { family: Theme.fontFamily; pixelSize: 10 }
        }
    }
}
