from backend.tables import Base, Engine


def write_data(reports):
    Base.metadata.create_all(Engine)
