import QtQuick

Item {
  id: root
  signal toggleWeather()

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  property string weatherFg: Theme.fg

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 5

    Text {
      text: WeatherModule.loading ? "--" : Math.round(WeatherModule.temp) + "°"
      color: weatherFg
      font { family: Theme.fontFamily; pixelSize: 14; weight: 500 }
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: { console.log("weather clicked"); root.toggleWeather() }
  }
}
