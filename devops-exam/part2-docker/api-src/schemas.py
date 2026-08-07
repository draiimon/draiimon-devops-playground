from typing import Optional
from pydantic import BaseModel


class Trip(BaseModel):
    name: str
    description: Optional[str]
    # start_date: str
    # end_date: str
    joiner_total_count: int


class ShowTrip(Trip):
    pass
    
