from __future__ import annotations

from config import (

    DATABASE_URL,

    DB_HOST,

    DB_PORT,

    DB_NAME,

    DB_USER,

    DB_PASSWORD,

)

import logging
import time
from contextlib import contextmanager
from typing import Generator


from sqlalchemy import create_engine
from sqlalchemy import text

from sqlalchemy.orm import (
    declarative_base,
    sessionmaker,
    Session,
)

from sqlalchemy.exc import (

    SQLAlchemyError,

    OperationalError,

    IntegrityError,

)

# ==========================================================
# Logging Configuration
# ==========================================================

logging.basicConfig(

    level=logging.INFO,

    format="%(asctime)s | %(levelname)s | %(message)s"

)

logger = logging.getLogger("OptiCore.Database")

# ==========================================================
# SQLAlchemy Base
# ==========================================================

Base = declarative_base()

# ==========================================================
# Engine Configuration
# ==========================================================

engine = create_engine(

    DATABASE_URL,

    pool_size=20,

    max_overflow=40,

    pool_timeout=30,

    pool_recycle=1800,

    pool_pre_ping=True,

    echo=False,

    future=True,

)

# ==========================================================
# Session Factory
# ==========================================================

SessionLocal = sessionmaker(

    bind=engine,

    autoflush=False,

    autocommit=False,

    expire_on_commit=False,

    class_=Session,

)

# ==========================================================
# Database Connection Test
# ==========================================================

def test_connection() -> bool:
    """
    Test PostgreSQL connectivity.

    Returns
    -------
    bool
        True if connection succeeds.
    """

    try:

        with engine.connect() as connection:

            connection.execute(text("SELECT 1"))

        logger.info("Database connection successful.")

        return True

    except OperationalError as exc:

        logger.exception(
            "Commit failed."
        )

        return False

# ==========================================================
# Create Tables
# ==========================================================

def initialize_database() -> None:
    """
    Creates all database tables.
    """

    logger.info("Creating database tables...")

    Base.metadata.create_all(bind=engine)

    logger.info("Database initialized successfully.")

# ==========================================================
# Session Dependency
# ==========================================================

def get_session() -> Generator[Session, None, None]:
    """
    Returns a SQLAlchemy session.
    """

    session = SessionLocal()

    try:

        yield session

    finally:

        session.close()

# ==========================================================
# Context Manager
# ==========================================================

@contextmanager
def session_scope():

    """
    Automatic transaction management.

    Example:

        with session_scope() as session:

            ...

    """

    session = SessionLocal()

    try:

        yield session

        session.commit()

    except SQLAlchemyError:

        session.rollback()

        raise

    finally:

        session.close()

# ==========================================================
# Health Check
# ==========================================================

def database_health() -> dict:
    """
    Returns database status information.
    """

    start = time.perf_counter()

    try:

        with engine.connect() as connection:

            connection.execute(text("SELECT NOW()"))

        latency = round(

            (time.perf_counter() - start) * 1000,

            2,

        )

        return {

            "status": "Healthy",

            "latency_ms": latency,

            "database": DB_NAME,

            "host": DB_HOST,

        }

    except SQLAlchemyError as exc:

        return {

            "status": "Offline",

            "error": str(exc),

        }

# ==========================================================
# Database Manager
# ==========================================================

class DatabaseManager:
    """
    Enterprise Database Manager

    Features
    --------
    • Safe CRUD Operations
    • Automatic Retry
    • Bulk Inserts
    • Transaction Handling
    • SQL Execution
    • Database Statistics
    """
    
    def __init__(self):

        self.engine = engine

        self.session_factory = SessionLocal

    # ------------------------------------------------------

    def create_session(self) -> Session:

        """
        Returns a new SQLAlchemy session.
        """

        return self.session_factory()

    # ------------------------------------------------------

    def execute(self, query, params=None):

        """
        Execute raw SQL.
        """

        with self.engine.begin() as connection:

            return connection.execute(

                text(query),

                params or {}

            )

    # ------------------------------------------------------

    def fetch_one(self, query, params=None):

        """
        Returns one row.
        """

        result = self.execute(

            query,

            params,

        )

        return result.fetchone()

    # ------------------------------------------------------

    def fetch_all(self, query, params=None):

        """
        Returns all rows.
        """

        result = self.execute(

            query,

            params,

        )

        return result.fetchall()

    # ------------------------------------------------------

    def scalar(self, query, params=None):

        """
        Returns scalar value.
        """

        result = self.execute(

            query,

            params,

        )

        return result.scalar()

    # ------------------------------------------------------

    def table_exists(self, table_name: str) -> bool:

        query = """

        SELECT EXISTS (

            SELECT 1

            FROM information_schema.tables

            WHERE table_name = :table

        )

        """

        return self.scalar(

            query,

            {

                "table": table_name

            }

        )

    # ------------------------------------------------------

    def row_count(self, table_name: str):

        if table_name not in list_tables():
    
            raise ValueError(
    
                f"Unknown table: {table_name}"
    
            )
    
        query = f'SELECT COUNT(*) FROM "{table_name}"'
    
        return self.scalar(query)

    # ------------------------------------------------------

    def truncate_table(self, table_name: str):

        logger.warning(

            f"Truncating table: {table_name}"

        )

        self.execute(

            f"TRUNCATE TABLE {table_name} CASCADE"

        )

    # ------------------------------------------------------

    def drop_table(self, table_name: str):

        logger.warning(

            f"Dropping table: {table_name}"

        )

        self.execute(

            f"DROP TABLE IF EXISTS {table_name} CASCADE"

        )

    # ------------------------------------------------------

    def create_all(self):

        logger.info(

            "Creating database tables..."

        )

        Base.metadata.create_all(

            bind=self.engine

        )

    # ------------------------------------------------------

    def drop_all(self):

        logger.warning(

            "Dropping all database tables..."

        )

        Base.metadata.drop_all(

            bind=self.engine

        )

    # ------------------------------------------------------

    def commit(self, session: Session):

        try:

            session.commit()

        except IntegrityError as exc:

            session.rollback()

            logger.exception(
                "Commit failed."
            )

            raise

        except SQLAlchemyError as exc:

            session.rollback()

            logger.error(exc)

            raise

    # ------------------------------------------------------

    def rollback(self, session: Session):

        session.rollback()

    # ------------------------------------------------------

    def close(self, session: Session):

        session.close()
      
db = DatabaseManager()

# ==========================================================
# Retry Decorator
# ==========================================================

from functools import wraps
def retry_database_operation(

    retries=3,

    delay=2,

):

    """
    Retry database operations
    on temporary failures.
    """

    def decorator(function):
        @wraps(function)

        def wrapper(

            *args,

            **kwargs,

        ):

            last_exception = None

            for attempt in range(

                retries

            ):

                try:

                    return function(

                        *args,

                        **kwargs,

                    )

                except OperationalError as exc:

                    last_exception = exc

                    logger.warning(

                        f"Retry {attempt + 1}/{retries}"

                    )

                    time.sleep(delay)

            raise last_exception

        return wrapper

    return decorator

# ==========================================================
# Bulk Insert Helper
# ==========================================================

@retry_database_operation()

def bulk_insert(

    session: Session,

    objects: list,

):

    """
    High-performance insert.
    """

    try:

        session.bulk_save_objects(

            objects

        )

        session.commit()

        logger.debug(

            f"{len(objects)} rows inserted."

        )

    except SQLAlchemyError:

        session.rollback()

        raise

# ==========================================================
# Bulk Update Helper
# ==========================================================

@retry_database_operation()

def bulk_update(

    session: Session,

    objects,

):

    try:

        session.bulk_save_objects(

            objects,

            update_changed_only=True,

        )

        session.commit()

    except SQLAlchemyError:

        session.rollback()

        raise

# ==========================================================
# Bulk Delete Helper
# ==========================================================

def bulk_delete(

    session: Session,

    model,

):

    deleted = session.query(

        model

    ).delete()

    session.commit()

    return deleted

# ==========================================================
# Generic CRUD Helpers
# ==========================================================

@retry_database_operation()
def add(session: Session, obj):
    """
    Add a single ORM object.
    """

    try:

        session.add(obj)

        session.commit()

        session.refresh(obj)

        return obj

    except SQLAlchemyError:

        session.rollback()

        raise


# ----------------------------------------------------------

@retry_database_operation()
def add_many(session: Session, objects):

    """
    Insert multiple ORM objects.
    """

    try:

        session.add_all(objects)

        session.commit()

        return objects

    except SQLAlchemyError:

        session.rollback()

        raise


# ----------------------------------------------------------

def get_by_id(

    session: Session,

    model,

    object_id,

):

    """
    Retrieve an object by primary key.
    """

    return session.get(

        model,

        object_id,

    )


# ----------------------------------------------------------

def get_all(

    session: Session,

    model,

):

    """
    Return all rows.
    """

    return (

        session.query(model)

        .all()

    )


# ----------------------------------------------------------

def delete(

    session: Session,

    obj,

):

    """
    Delete one ORM object.
    """

    try:

        session.delete(obj)

        session.commit()

    except SQLAlchemyError:

        session.rollback()

        raise


# ----------------------------------------------------------

def update(

    session: Session,

):

    """
    Commit pending updates.
    """

    try:

        session.commit()

    except SQLAlchemyError:

        session.rollback()

        raise


# ==========================================================
# Database Statistics
# ==========================================================

def database_statistics():

    """
    Returns PostgreSQL statistics.
    """

    stats = {}

    with engine.connect() as connection:

        stats["database"] = connection.execute(

            text(

                "SELECT current_database()"

            )

        ).scalar()

        stats["version"] = connection.execute(

            text(

                "SELECT version()"

            )

        ).scalar()

        stats["current_user"] = connection.execute(

            text(

                "SELECT current_user"

            )

        ).scalar()

        stats["server_time"] = connection.execute(

            text(

                "SELECT NOW()"

            )

        ).scalar()

    return stats


# ==========================================================
# Connection Pool Statistics
# ==========================================================

def connection_pool_status():

    """
    Returns SQLAlchemy pool info.
    """

    pool = engine.pool

    return {

        "size": pool.size(),

        "checked_in": pool.checkedin(),

        "checked_out": pool.checkedout(),

        "overflow": pool.overflow(),

    }


# ==========================================================
# Database Size
# ==========================================================

def database_size():

    query = """

    SELECT

    pg_size_pretty(

        pg_database_size(

            current_database()

        )

    )

    """

    return db.scalar(query)


# ==========================================================
# Existing Tables
# ==========================================================

def list_tables():

    query = """

    SELECT

        table_name

    FROM

        information_schema.tables

    WHERE

        table_schema='public'

    ORDER BY

        table_name;

    """

    rows = db.fetch_all(query)

    return [

        row[0]

        for row in rows

    ]


# ==========================================================
# Table Row Count
# ==========================================================

def table_statistics():

    statistics = {}

    for table in list_tables():

        try:

            statistics[table] = db.row_count(table)

        except SQLAlchemyError:

            statistics[table] = None

    return statistics


# ==========================================================
# Execute SQL Script
# ==========================================================

def execute_sql_file(

    file_path: str,

):

    """
    Executes a .sql file.
    """

    with open(

        file_path,

        "r",

        encoding="utf-8",

    ) as file:

        sql = file.read()

    with engine.begin() as connection:

        connection.execute(

            text(sql)

        )

    logger.info(

        f"Executed {file_path}"

    )


# ==========================================================
# Reset Database
# ==========================================================

def reset_database():

    """
    Drops and recreates all tables.
    """

    logger.warning(

        "Resetting database..."

    )

    Base.metadata.drop_all(

        bind=engine

    )

    Base.metadata.create_all(

        bind=engine

    )

    logger.info(

        "Database reset complete."

    )


# ==========================================================
# Verify Connection
# ==========================================================

def verify_connection():

    """
    Raises an exception if the
    database is unavailable.
    """

    with engine.connect() as connection:

        connection.execute(

            text("SELECT 1")

        )

    logger.info(

        "Database verified."

    )

# ==========================================================
# Database Health Report
# ==========================================================

def health_report() -> dict:
    """
    Returns a comprehensive database health report.
    """

    report = {}

    report["connection"] = test_connection()

    report["database"] = database_statistics()

    report["pool"] = connection_pool_status()

    report["size"] = database_size()

    report["tables"] = table_statistics()

    report["status"] = (

        "Healthy"

        if report["connection"]

        else "Offline"

    )

    return report


# ==========================================================
# Database Backup
# ==========================================================

def backup_database(output_file: str):

    """
    Creates a SQL dump using pg_dump.

    PostgreSQL must be installed locally.
    """

    import subprocess
    import shutil

    if shutil.which("pg_dump") is None:
    
        raise RuntimeError(
    
            "pg_dump executable not found."
    
        )

    command = [

        "pg_dump",

        "-h",

        DB_HOST,

        "-p",

        str(DB_PORT),

        "-U",

        DB_USER,

        "-F",

        "p",

        "-f",

        output_file,

        DB_NAME,

    ]

    subprocess.run(

        command,

        check=True,

    )

    logger.info(

        f"Database backup created: {output_file}"

    )


# ==========================================================
# Restore Database
# ==========================================================

def restore_database(sql_file: str):

    """
    Restores database from SQL dump.
    """

    import subprocess
    import shutil
  
    if shutil.which("psql") is None:
    
        raise RuntimeError(
    
            "psql executable not found."
    
        )

    command = [

        "psql",

        "-h",

        DB_HOST,

        "-p",

        str(DB_PORT),

        "-U",

        DB_USER,

        "-d",

        DB_NAME,

        "-f",

        sql_file,

    ]

    subprocess.run(

        command,

        check=True,

    )

    logger.info(

        f"Database restored from {sql_file}"

    )


# ==========================================================
# Database Startup
# ==========================================================

def startup():

    """
    Initializes database on application startup.
    """

    logger.info(

        "=" * 60

    )

    logger.info(

        "Starting OptiCore Database..."

    )

    if not test_connection():

        raise RuntimeError(

            "Unable to connect to PostgreSQL."

        )

    initialize_database()

    logger.info(

        "Database ready."

    )

    logger.info(

        "=" * 60

    )


# ==========================================================
# Shutdown
# ==========================================================

def shutdown():

    """
    Gracefully disposes the SQLAlchemy engine.
    """

    logger.info(

        "Closing database engine..."

    )

    engine.dispose()

    logger.info(

        "Database engine closed."

    )


# ==========================================================
# Public Exports
# ==========================================================

__all__ = [

    "Base",

    "engine",

    "SessionLocal",

    "DatabaseManager",

    "db",

    "initialize_database",

    "test_connection",

    "database_health",

    "health_report",

    "database_statistics",

    "connection_pool_status",

    "database_size",

    "list_tables",

    "table_statistics",

    "get_session",

    "session_scope",

    "bulk_insert",

    "bulk_update",

    "bulk_delete",

    "add",

    "add_many",

    "get_by_id",

    "get_all",

    "delete",

    "update",

    "execute_sql_file",

    "reset_database",

    "verify_connection",

    "backup_database",

    "restore_database",

    "startup",

    "shutdown",

]
