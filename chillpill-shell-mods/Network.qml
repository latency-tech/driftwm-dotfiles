import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
  property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

  Text {
      text: {
          if (!Networking.wifiEnabled) return "disconnected"
          if (!root.active) return "N/A"
          return root.active.name
      }
      color: Theme.fg
      font { family: Theme.fontFamily; pixelSize: 14; weight: 500 }
      elide: Text.ElideRight
      Layout.maximumWidth: 90
  }
}
