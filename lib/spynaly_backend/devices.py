from models import DeviceResponse, Device

def get_user_devices(user_id: str) -> DeviceResponse:
    return DeviceResponse(
        user_id=user_id,
        devices=[
            Device(
                device_id="1234",
                device_type="Android",
                location="Riyadh",
                last_active="2025-04-10 14:32"
            ),
            Device(
                device_id="5678",
                device_type="Web",
                location="Jeddah",
                last_active="2025-04-11 09:12",
                is_new=True
            )
        ]
    )
