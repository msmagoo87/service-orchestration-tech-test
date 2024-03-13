from confection import registry, Config
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from redis import Redis

app = FastAPI()

config = registry.resolve(Config().from_disk('/etc/config/service.cfg'))
REDIS_HOST = config['redis']['host']
REDIS_PORT = config['redis']['port']
r = Redis(host=REDIS_HOST, port=REDIS_PORT, db=0, decode_responses=True)

class ShortenRequest(BaseModel):
    url: str


@app.post("/pw/{key}/{value}")
async def crud_set(key: str, value: str):
    """
    Set `key` to `value` in redis
    """
    r.set(key, value)
    short_url = "new-short-url"
    return {"key": f"{key}", "value": f"{value}"}


class ResolveRequest(BaseModel):
    short_url: str


@app.get("/pw/{key}")
async def crud_get(key: str):
    """
    Get `key` from redis
    """
    v = r.get(key)
    if v is None:
       raise HTTPException(status_code=404, detail="Key not found")
    return r.get(key)


@app.delete("/pw/{key}")
async def crud_get(key: str):
    """
    Get `key` from redis
    """
    return r.delete(key)


@app.get("/pw")
async def index():
    return "Your redis crud server is running!"
