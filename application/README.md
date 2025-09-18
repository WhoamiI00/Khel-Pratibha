
# Khel Pratibha: AI-Powered Sports Talent Assessment 

Khel Pratibha is an AI-powered mobile platform designed to democratize sports talent assessment across India. Developed for the Smart India Hackathon 2025 by team Prompt AI-liance, 
this project aims to give every aspiring athlete a fair chance to showcase their abilities, regardless of their location or resources.

Problem Statement ID: 25073
Prototype Link: [https://github.com/Whoamil00/Khel-Pratibha]



# Objective

Our goal is to create a scalable, accessible, and unbiased system for identifying athletic talent from the grassroots level. By leveraging on-device AI, we eliminate the need for expensive equipment and manual scouting camps, creating a level playing field for all.



# Key Features & Innovation

  * On-Device, Offline-First AI: All video analysis happens directly on the user's smartphone, requiring no internet connection to process the performance. This ensures accessibility even in remote areas and saves significant data costs.

  * Real-Time Pose Estimation: The app uses Google's MediaPipe and MoveNet models to track 17 body joints in real-time for accurate performance analysis.

  * Instant Feedback & Benchmarking: Athletes receive immediate, objective scores for their fitness tests (e.g., jump height, sit-up reps, sprint times) and can compare their performance against district, state, and national averages for their age group.

  * Gamified Motivation: To encourage consistent participation, the app includes features like badges, leaderboards, and personal best tracking.
  
  * Secure & Lightweight Data: Instead of uploading heavy video files, the app only sends a small, encrypted packet of verified results and metadata to the server, ensuring efficiency and security.



# How It Works: The Four Steps

The entire process is streamlined into four simple steps:

1. Capture: An athlete uses the Khel Pratibha mobile app to record their performance in various fitness tests like vertical jumps, sit-ups, and shuttle runs. The app provides guided tutorials to ensure consistency.

2. Analyze: The on-device AI model (MoveNet on TensorFlow Lite) instantly analyzes the video feed. It performs kinematic analysis to calculate objective metrics, such as jump height based on hip displacement or sit-up reps based on torso angles.

3. Verify & Secure: Once the analysis is complete, the app generates a lightweight, encrypted data packet containing the verified results. This packet is uploaded to the cloud server.

4. Scout & Evaluate: Officials from the Sports Authority of India (SAI) can log into a central dashboard to view and analyze the performance data from athletes across the nation, enabling transparent and bias-free scouting.



# Tech Stack

The platform is built using a modern and scalable tech stack:

  * Mobile App: Flutter (Dart) 
  * AI / ML: MediaPipe, MoveNet, TensorFlow Lite (TFLite)
  * Backend: Django (Python)
  * Database: PostgreSQL / Supabase 
  * Admin Dashboard: React.js 
  * Hosting: AWS or GCP



# Impact and Benefits

This project stands to revolutionize the sports ecosystem in India.

# For Athletes

  * Provides a free and direct pathway to get noticed by national authorities.
  * Offers instant, actionable feedback to help improve training and performance.
  * Motivates through engaging and gamified challenges.

# For the Sports Authority of India (SAI)

  * Massively expands the scouting reach at a fraction of traditional costs.
  * Enables faster, data-driven, and more efficient talent shortlisting.
  * Creates a long-term national database for athlete development and monitoring.

# For the Indian Sports Ecosystem

  * Builds a continuous grassroots-to-national talent pipeline.
  * Strengthens India's ability to identify and nurture world-class athletes for the future.



# Getting Started

Follow these instructions to get a local copy of the project up and running for development and testing purposes.

# Prerequisites

Make sure you have the following software installed on your system:

  * Git
  * Python & Pip
  * Flutter SDK

# 1. Clone the Repository

First, clone the project repository from GitHub.

```bash
git clone https://github.com/Whoamil00/Khel-Pratibha.git
cd Khel-Pratibha
```

# 2. Backend Setup (Django)

Follow these steps to get the backend server running.

```bash
# Navigate to the backend directory
cd backend

# Create and activate a Python virtual environment
# On macOS/Linux:
python3 -m venv venv
source venv/bin/activate

# On Windows:
python -m venv venv
.\venv\Scripts\activate

# Install the required dependencies
pip install -r requirements.txt

# Apply the database migrations
python manage.py migrate

# Run the Django development server
python manage.py runserver
```

Your Django backend should now be running at `http://127.0.0.1:8000/`.

# 3. Frontend Setup (Flutter Mobile App)

In a new terminal, set up and run the Flutter application.

```bash
# Navigate to the application directory from the root folder
cd application

# Install the required Flutter packages
flutter pub get

# Run the application
# Make sure you have a device connected or an emulator running
flutter run
```

The mobile app will now build and launch on your selected device/emulator, connecting to the local backend server.



# Team
Prompt AI-liance - Smart India Hackathon 2025
