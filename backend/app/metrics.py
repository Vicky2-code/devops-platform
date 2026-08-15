from prometheus_client import CollectorRegistry, Counter, Gauge, Histogram

registry = CollectorRegistry()

# HTTP request metrics
http_requests_total = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ("method", "path", "status"),
    registry=registry,
)
http_request_duration_seconds = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ("method", "path"),
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5),
    registry=registry,
)

# Domain metrics
deployments_total = Counter("deployments_total", "Total deployments", ("status",), registry=registry)
jobs_total = Counter("jobs_total", "Total automation jobs", ("kind", "status"), registry=registry)
projects_gauge = Gauge("projects_total", "Current number of projects", registry=registry)
