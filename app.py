import streamlit as st

from config import (
    APP_NAME,
    APP_ICON,
    APP_LAYOUT,
    SIDEBAR_STATE,
)

# Core
from core.navigation import NavigationManager
from core.state_manager import initialize_session

# Authentication
from authentication.session import check_login

# Components
from components.sidebar import render_sidebar

# Database
from database.db import initialize_database


# ==========================================================
# Streamlit Configuration
# ==========================================================

st.set_page_config(

    page_title=APP_NAME,

    page_icon=APP_ICON,

    layout=APP_LAYOUT,

    initial_sidebar_state=SIDEBAR_STATE,

)

# ==========================================================
# Initialize Application
# ==========================================================

initialize_session()

initialize_database()

# ==========================================================
# Authentication
# ==========================================================

if not check_login():

    st.stop()

# ==========================================================
# Sidebar
# ==========================================================

render_sidebar()

# ==========================================================
# Navigation
# ==========================================================

navigator = NavigationManager()

navigator.run()
