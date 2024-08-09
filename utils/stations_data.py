import json
from datetime import datetime, timedelta
import scipy.stats

devices = [{
    "name": "weather-station-001",
    "lat": 30.30,
    "lon": -97.69,
    "rain": [{
        "start": datetime.fromisoformat("2024-01-02"),
        "duration": timedelta(hours=4),
        "rainfall_mm": 10,
        "distribution": (2, 5),
    }, {
        "start": datetime.fromisoformat("2024-01-10"),
        "duration": timedelta(hours=48),
        "rainfall_mm": 25,
        "distribution": (2, 5),
    }, {
        "start": datetime.fromisoformat("2024-01-12"),
        "duration": timedelta(hours=8),
        "rainfall_mm": 10,
        "distribution": (3, 3),
    }, {
        "start": datetime.fromisoformat("2024-01-20"),
        "duration": timedelta(hours=24),
        "rainfall_mm": 20,
        "distribution": (2, 5),
    }]
}, {
    "name": "weather-station-002",
    "lat": 28.48,
    "lon": -98.34,
    "rain": [{
        "start": datetime.fromisoformat("2024-01-10"),
        "duration": timedelta(hours=40),
        "rainfall_mm": 10,
        "distribution": (4, 2),
    }, {
        "start": datetime.fromisoformat("2024-01-12"),
        "duration": timedelta(hours=8),
        "rainfall_mm": 7,
        "distribution": (2, 3),
    }, {
        "start": datetime.fromisoformat("2024-01-20"),
        "duration": timedelta(hours=24),
        "rainfall_mm": 10,
        "distribution": (3, 2),
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
                relpos = (t - r["start"]).total_seconds() / r["duration"].total_seconds()
                if relpos >= 0 and relpos < 1:
                    mm_per_interval = float(r["rainfall_mm"]) / (r["duration"].total_seconds() / step.total_seconds())
                    alpha, beta = r['distribution']
                    precip_interval = float(scipy.stats.beta.pdf(relpos, alpha, beta)) * mm_per_interval
                    precip += precip_interval
            
            v["event_time"] = t.isoformat()
            v["precipitation_accumulated"] = round(precip, 3)
            json.dump(v, f)
            f.write('\n')

            t += step
