#!/bin/sh
[ "$1" = python3-sqlalchemy ] || exit 0
python3 - << 'EOF'
import sqlalchemy
assert sqlalchemy.__version__, "sqlalchemy version is empty"

from sqlalchemy import create_engine, Column, Integer, String, text
from sqlalchemy.orm import DeclarativeBase, Session

engine = create_engine("sqlite:///:memory:")

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String)

Base.metadata.create_all(engine)

with Session(engine) as session:
    session.add(User(name="Alice"))
    session.add(User(name="Bob"))
    session.commit()
    users = session.query(User).order_by(User.name).all()
    assert len(users) == 2
    assert users[0].name == "Alice"
    assert users[1].name == "Bob"

with engine.connect() as conn:
    result = conn.execute(text("SELECT count(*) FROM users"))
    count = result.scalar()
    assert count == 2, f"Expected 2, got {count}"
EOF
