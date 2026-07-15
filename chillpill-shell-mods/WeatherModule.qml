pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property real temp: 0
  property real feelsLike: 0
  property int humidity: 0
  property real windSpeed: 0
  property string windDir: ""
  property int uvIndex: 0
  property string condition: ""
  property string weatherCode: ""
  property string iconGlyph: "\ue312"
  property string iconColor: "#9aa0a6"
  property string sunrise: ""
  property string sunset: ""
  property var forecast: []
  property bool loading: false
  property string errorMessage: ""
  property var lastUpdated: new Date()

  function wmoToInfo(code) {
    code = parseInt(code) || 0
    if (code === 0)  return { glyph: "\ue30d", color: "#f4c542", desc: "Clear sky" }
    if (code === 1)  return { glyph: "\ue30d", color: "#f4c542", desc: "Mainly clear" }
    if (code === 2)  return { glyph: "\ue312", color: "#c8c8c8", desc: "Partly cloudy" }
    if (code === 3)  return { glyph: "\ue312", color: "#9aa0a6", desc: "Overcast" }
    if (code === 45 || code === 48) return { glyph: "\ue313", color: "#8a8a8a", desc: "Fog" }
    if (code >= 51 && code <= 57) return { glyph: "\ue318", color: "#7ab8e0", desc: "Drizzle" }
    if (code >= 61 && code <= 67) return { glyph: "\ue318", color: "#4a9de8", desc: "Rain" }
    if (code >= 71 && code <= 77) return { glyph: "\ue31a", color: "#d8e8f4", desc: "Snow" }
    if (code >= 80 && code <= 82) return { glyph: "\ue319", color: "#4a9de8", desc: "Rain showers" }
    if (code >= 85 && code <= 86) return { glyph: "\ue31a", color: "#d8e8f4", desc: "Snow showers" }
    if (code === 95) return { glyph: "\ue31d", color: "#e8b84a", desc: "Thunderstorm" }
    if (code >= 96)  return { glyph: "\ue31d", color: "#e87a4a", desc: "Thunderstorm + hail" }
    return { glyph: "\ue312", color: "#9aa0a6", desc: "Unknown" }
  }

  Process {
    id: weatherProc
    command: ["sh", "-c",
      "curl -s --max-time 10 'https://api.open-meteo.com/v1/forecast?latitude=44.75525&longitude=33.85782&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=Europe/Simferopol&forecast_days=7'"
    ]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        root.loading = false
        const text = this.text.trim()
        if (text.length < 10 || !text.startsWith("{")) {
          root.errorMessage = "Weather fetch failed"
          return
        }
        try {
          const d = JSON.parse(text)

          const c = d.current
          root.temp = c.temperature_2m || 0
          root.feelsLike = c.apparent_temperature || 0
          root.humidity = c.relative_humidity_2m || 0
          root.windSpeed = c.wind_speed_10m || 0

          const code = c.weather_code
          root.weatherCode = String(code)
          const info = root.wmoToInfo(code)
          root.iconGlyph = info.glyph
          root.iconColor = info.color
          root.condition = info.desc

          const daily = d.daily
          if (daily.sunrise && daily.sunrise.length > 0) {
            root.sunrise = daily.sunrise[0].split("T")[1] || ""
            root.sunset = (daily.sunset && daily.sunset.length > 0) ? daily.sunset[0].split("T")[1] : ""
          }

          const days = []
          const count = Math.min(daily.time.length, 7)
          for (var i = 0; i < count; i++) {
            const di = root.wmoToInfo(daily.weather_code[i])
            days.push({
              date: daily.time[i],
              maxTemp: daily.temperature_2m_max[i],
              minTemp: daily.temperature_2m_min[i],
              iconGlyph: di.glyph,
              iconColor: di.color,
              desc: di.desc
            })
          }
          root.forecast = days

          root.lastUpdated = new Date()
        } catch (e) {
          root.errorMessage = "Weather parse failed: " + e.message
        }
      }
    }
  }

  function refresh() {
    root.loading = true
    root.errorMessage = ""
    weatherProc.running = false
    weatherProc.running = true
  }

  Timer {
    interval: Config.weatherRefreshInterval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
