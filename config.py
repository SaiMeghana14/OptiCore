"""
==========================================================
OptiCore - Intelligent Business Operations Platform

Configuration Manager

Author: Sai Meghana K
==========================================================
"""

from pathlib import Path
import streamlit as st


# ==========================================================
# Project Directories
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent

ASSETS_DIR = BASE_DIR / "assets"

DATA_DIR = BASE_DIR / "data"

RAW_DATA_DIR = DATA_DIR / "raw"

PROCESSED_DATA_DIR = DATA_DIR / "processed"

UPLOAD_DIR = DATA_DIR / "uploads"

EXPORT_DIR = DATA_DIR / "exports"

DATABASE_DIR = BASE_DIR / "database"

MODEL_DIR = BASE_DIR / "ml_models"

REPORT_DIR = BASE_DIR / "exports"

LOG_DIR = BASE_DIR / "logs"


# ==========================================================
# Application
# ==========================================================

APP_NAME = "OptiCore"

APP_VERSION = "1.0.0"

APP_ICON = "📊"

APP_LAYOUT = "wide"

SIDEBAR_STATE = "expanded"


# ==========================================================
# Theme
# ==========================================================

PRIMARY_COLOR = "#3B82F6"

SECONDARY_COLOR = "#10B981"

WARNING_COLOR = "#F59E0B"

DANGER_COLOR = "#EF4444"

BACKGROUND_COLOR = "#0F172A"

CARD_COLOR = "#1E293B"

TEXT_COLOR = "#F8FAFC"


# ==========================================================
# Database
# ==========================================================

DB_HOST = st.secrets["DB_HOST"]

DB_PORT = st.secrets["DB_PORT"]

DB_NAME = st.secrets["DB_NAME"]

DB_USER = st.secrets["DB_USER"]

DB_PASSWORD = st.secrets["DB_PASSWORD"]

DATABASE_URL = (
    f"postgresql://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


# ==========================================================
# Gemini
# ==========================================================

GEMINI_API_KEY = st.secrets["GEMINI_API_KEY"]


# ==========================================================
# Reports
# ==========================================================

EXPORT_EXCEL = EXPORT_DIR / "excel"

EXPORT_PDF = EXPORT_DIR / "pdf"

EXPORT_CSV = EXPORT_DIR / "csv"


# ==========================================================
# Upload
# ==========================================================

MAX_UPLOAD_MB = 100

SUPPORTED_FILES = [

    "csv",

    "xlsx",

    "xls"

]


# ==========================================================
# Machine Learning
# ==========================================================

MODEL_PATH = MODEL_DIR

CONFIDENCE_THRESHOLD = 0.75


# ==========================================================
# Pagination
# ==========================================================

ROWS_PER_PAGE = 25


# ==========================================================
# Dashboard Refresh
# ==========================================================

AUTO_REFRESH_SECONDS = 60


# ==========================================================
# KPI Thresholds
# ==========================================================

LOW_STOCK_THRESHOLD = 20

SUPPLIER_SCORE_THRESHOLD = 75

CUSTOMER_SATISFACTION_THRESHOLD = 80

FULFILLMENT_THRESHOLD = 90

RETURN_RATE_THRESHOLD = 8


# ==========================================================
# Alerts
# ==========================================================

ALERT_LEVELS = [

    "Info",

    "Warning",

    "Critical"

]


# ==========================================================
# Logging
# ==========================================================

LOG_LEVEL = "INFO"


# ==========================================================
# AI
# ==========================================================

MAX_AI_TOKENS = 2048

AI_MODEL = "gemini-2.5-pro"


# ==========================================================
# Misc
# ==========================================================

DEMO_MODE = False
