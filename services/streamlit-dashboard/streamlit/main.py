import streamlit as st
from PIL import Image
st.set_page_config(layout="wide", page_title="Osher Data dashboards")


with st.container():
    # header
    col1, col2 = st.columns([1,3])
    logo = Image.open('pics/me.jpg')
    col1.image(logo)
    col2.title(f'🎈 Welcome to Osher\'s data analytic dashboards')

st.write('Please select a report from the sidebar.')
st.write('You can change the theme color in the setting (Right above menu --> Settings --> Theme).')