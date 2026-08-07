from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DB_CONNECTION_STRING = os.getenv(
    "DB_CONNECTION_STRING", "mysql+pymysql://root:password@localhost:3306/testdb")

# Create the engine
engine = create_engine(DB_CONNECTION_STRING)

# Test the connection
# with engine.connect() as connection:
#     result = connection.execute("SELECT * FROM users")
#     for row in result:
#         print(row)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
