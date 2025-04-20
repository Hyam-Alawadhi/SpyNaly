from pydantic import BaseModel
from typing import List, Optional

class Device(BaseModel):
    device_id: str
    device_type: str
    location: Optional[str]
    last_active: Optional[str]
    is_new: Optional[bool] = False

class DeviceResponse(BaseModel):
    user_id: str
    devices: List[Device]
