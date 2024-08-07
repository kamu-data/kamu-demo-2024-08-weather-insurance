import json
from datetime import datetime, timedelta

devices = [{
    "name": "weather-station-001",
    "lat": 30.30,
    "lon": -97.69,
    "rain": [{
        "t": datetime.fromisoformat("2024-01-10"),
        "d": timedelta(hours=24),
        "mm": 15,
    }, {
        "t": datetime.fromisoformat("2024-01-11"),
        "d": timedelta(hours=8),
        "mm": 5,
    }, {
        "t": datetime.fromisoformat("2024-01-20"),
        "d": timedelta(hours=24),
        "mm": 20,
    }]
}, {
    "name": "weather-station-002",
    "lat": 28.48,
    "lon": -98.34,
    "rain": [{
        "t": datetime.fromisoformat("2024-01-10"),
        "d": timedelta(hours=24),
        "mm": 10,
    }, {
        "t": datetime.fromisoformat("2024-01-11"),
        "d": timedelta(hours=8),
        "mm": 7,
    }, {
        "t": datetime.fromisoformat("2024-01-20"),
        "d": timedelta(hours=24),
        "mm": 10,
    }]
}]

start = datetime.fromisoformat("2024-01-01T00:00:00")
end = datetime.fromisoformat("2024-01-31T23:59:59")
step = timedelta(minutes=1)

for device in devices:
    v = {
        "event_time": None, 
        "lat": device["lat"],
        "lon": device["lat"], 
        "precipitation_accumulated": 0,
    }

    with open(f"data/{device['name']}.ndjson", "w") as f:
        precip = 0.0
        t = start
        while t <= end:
            for r in device["rain"]:
                relpos = (t - r["t"]).total_seconds() / r["d"].total_seconds()
                if relpos >= 0 and relpos < 1:
                    precip += float(r["mm"]) / (r["d"].total_seconds() / step.total_seconds())
            
            v["event_time"] = t.isoformat()
            v["precipitation_accumulated"] = precip
            json.dump(v, f)
            f.write('\n')

            t += step
