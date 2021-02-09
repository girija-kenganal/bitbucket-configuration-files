# Create RMS
CREATE USER weir_rms WITH PASSWORD 'sa1f78f49e437288039751654ece96ede';
CREATE database weir_rms;
GRANT CONNECT ON DATABASE weir_rms TO weir_rms;
GRANT CREATE ON DATABASE weir_rms TO weir_rms;


# Create ROUTER
CREATE USER weir_router WITH PASSWORD 'sa1f78f49e437288039751654ece96ede';
CREATE database weir_router;
GRANT CONNECT ON DATABASE weir_router TO weir_router;
GRANT CREATE ON DATABASE weir_router TO weir_router;
