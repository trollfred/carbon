CREATE TABLE CarbonIntensity
(
    time         TIMESTAMP NOT NULL,
    intencity    SINT64,
    PRIMARY KEY (
        (QUANTUM(time, 30, 'm')), time
    )
)
