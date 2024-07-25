"""momaek/authy to 2FAS JSON schema converter"""

import dataclasses
import json
import time
from os.path import expanduser
from urllib.parse import quote


class EnhancedJSONEncoder(json.JSONEncoder):
    """
    JSON encoder supporting serialisation of dataclasses
    https://stackoverflow.com/a/51286749/5209106
    """
    def default(self, o):
        if dataclasses.is_dataclass(o):
            return dataclasses.asdict(o)
        return super().default(o)

@dataclasses.dataclass
class ServiceOtp:
    """2FAS service OTP schema"""
    link: str
    label: str
    account: str
    issuer: str
    tokenType: str = "TOTP"
    source: str = "Authy"


@dataclasses.dataclass
class ServiceOrder:
    """2FAS service order schema"""
    position: int


@dataclasses.dataclass
class ServiceIconLabel:
    """2FAS service icon label schema"""
    text: str
    backgroundColor: str = "Turquoise"


@dataclasses.dataclass
class ServiceIconCollection:
    """2FAS service icon collection schema"""
    id: str


@dataclasses.dataclass
class ServiceIcon:
    """2FAS service icon schema"""
    label: ServiceIconLabel
    iconCollection: ServiceIconCollection
    selected: str = "Label"


@dataclasses.dataclass
class Service:
    """2FAS Service schema"""
    name: str
    secret: str
    updatedAt: int
    serviceTypeID: str
    otp: ServiceOtp
    order: ServiceOrder
    icon: ServiceIcon


with open(expanduser('~/Downloads/2fas_example.2fas'), 'r', encoding='utf-8') as f:
    twofas = json.load(f)

services: list[Service] = []

with open(expanduser('~/Downloads/authy.json'), 'r', encoding='utf-8') as f:
    data = json.load(f)
    service_count = 0
    for svc in data:
        issuer = svc['name'].split(":")[0].strip()
        account = svc['name'].split(":")[-1].strip()

        services.append(
            Service(
                name = issuer,
                secret = svc['secret'],
                updatedAt = int(time.time()),
                serviceTypeID = "89efcc2d-52f4-4ac3-988d-5d7f3b3cd0a7",
                otp = ServiceOtp(
                    link = quote(f"otpauth://totp/{account}?secret={svc['secret']}&issuer={issuer}"),
                    label = account,
                    account = account,
                    issuer = issuer
                ),
                order = ServiceOrder(
                    position = service_count
                ),
                icon = ServiceIcon(
                    selected = "Label",
                    label = ServiceIconLabel(
                        text = issuer[:2],
                        backgroundColor = "Turquoise"
                    ),
                    iconCollection = ServiceIconCollection(
                        id = "a5b3fb65-4ec5-43e6-8ec1-49e24ca9e7ad"
                    )
                )
            )
        )

        service_count += 1

with open(expanduser('~/Downloads/2fas_from_authy.2fas'), 'w', encoding='utf-8') as f:
    data = twofas
    data['services'] = services
    json.dump(data, f, cls=EnhancedJSONEncoder)
