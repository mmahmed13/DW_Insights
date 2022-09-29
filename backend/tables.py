from uuid import uuid4

from sqlalchemy import Column, String, ForeignKey, Boolean, BigInteger, TIMESTAMP, JSON, Numeric, ForeignKeyConstraint, \
    Text
from sqlalchemy import create_engine
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.ext.declarative import declarative_base

Engine = create_engine('postgresql://postgres:postgres@localhost:5432/dw_reports')
Base = declarative_base()

class Page(Base):
    __tablename__ = 'page'
    __table_args__ = {'schema': 'reports'}

    facebook_id = Column(BigInteger, primary_key=True)
    page_name = Column(String)
    user_name = Column(String)
    page_category = Column(String)
    page_admin_top_country = Column(String(2))
    page_description = Column(Text)
    page_created = Column(TIMESTAMP)
    # user_name = relationship("MobilePhone", uselist=False, back_populates="person")
    # id = Column(Integer, primary_key=True)
    # comments = relationship("Comment")


class Post(Base):
    __tablename__ = 'post'
    __table_args__ = {'schema': 'reports'}

    post_created = Column(TIMESTAMP, primary_key=True)
    page_facebook_id = Column(BigInteger, ForeignKey('reports.page.facebook_id', ondelete='CASCADE'), primary_key=True)
    video_share_status = Column(String)
    is_video_owner = Column(Boolean)
    video_length = Column(TIMESTAMP)
    url = Column(String, nullable=False)
    message = Column(Text)
    link = Column(String, nullable=False)
    final_link = Column(String)
    image_text = Column(Text)
    sponsor_id = Column(BigInteger, ForeignKey('reports.sponsor.sponsor_id', ondelete='CASCADE'))


class Post_Statistics(Base):
    __tablename__ = 'post_statistics'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    timestamp = Column(TIMESTAMP, nullable=False)
    interactions = Column(JSON)
    post_views = Column(Numeric)
    total_views = Column(Numeric)
    total_views_for_all_crossposts = Column(Numeric)
    post_created = Column(TIMESTAMP)
    page_facebook_id = Column(BigInteger)

    __table_args__ = (ForeignKeyConstraint([post_created, page_facebook_id],
                                           [Post.post_created, Post.page_facebook_id],
                                           onupdate="CASCADE", match='FULL'),
                      {'schema': 'reports'})


class Sponsor(Base):
    __tablename__ = 'sponsor'
    __table_args__ = {'schema': 'reports'}

    sponsor_id = Column(BigInteger, primary_key=True)
    sponsor_name = Column(String)
    sponsor_category = Column(String)
