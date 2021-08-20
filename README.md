# Carbon

## Building

```
docker-compose build
```

## Starting storage

```
docker-compose up riakts_c riakts
```

This should start RiakTS cluster for storing carbon intensity points.

Riakts WebGUI is available at

```
http://localhost:8098/admin
```

## Starting poller

```
docker-compose up --no-deps carbon
```

If storage is empty, poller is going to populate data from the beginning of 2021.
After that it will be sleeping most of the time, periodically checking api for new data.


## Tests

```
mix test --no-start
```
