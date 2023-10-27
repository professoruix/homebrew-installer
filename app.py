import os
import shutil
import subprocess
import time
from flask_cors import CORS

from flask import Flask, request, jsonify

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*", "headers": "*"}})


class EditorService:
    def __init__(self):
        self.language_images = {
            'python': 'python:3.9-slim',
            'javascript': 'node:16',
        }

    def _install_language(self, language):
        image = self.language_images.get(language)
        if not image:
            raise ValueError(f"Unsupported language: {language}")

        cmd = ['docker', 'pull', image]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise RuntimeError(f"Failed to install {language}. Error: {result.stderr}")

    @staticmethod
    def _create_dockerfile(temp_dir):
        is_python = os.path.exists(os.path.join(temp_dir, 'requirements.txt'))
        is_node = os.path.exists(os.path.join(temp_dir, 'package.json'))

        if is_python:
            content = """FROM python:3.9-slim
    WORKDIR /app
    COPY . /app
    RUN pip install --no-cache-dir -r requirements.txt
    EXPOSE 4567
    CMD ["flask", "run", "--host=0.0.0.0", "--port=4567"]
    """
        elif is_node:
            content = """
    FROM node:16-alpine
    WORKDIR /app
    COPY . .
    RUN npm install
    EXPOSE 8000
    CMD ["npm", "start"]
    """
        else:
            raise ValueError("Unknown project type. Ensure it's a Python Flask or Node.js project.")

        with open(os.path.join(temp_dir, 'Dockerfile'), 'w') as file:
            file.write(content)

    @staticmethod
    def run_repo(repo_url, repo_name):
        temp_dir = f"/tmp/{repo_name}"

        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)

        cmd = [
            'git', 'clone',
            '--depth', '1',
            repo_url,
            temp_dir
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"Failed to clone the repo. Error: {result.stderr}")

        EditorService._create_dockerfile(temp_dir)

        image_name = f"{repo_name}"
        cmd = ['docker', 'build', '-t', image_name, temp_dir]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"Failed to build Docker image. Error: {result.stderr}")

        is_python = os.path.exists(os.path.join(temp_dir, 'requirements.txt'))
        is_node = os.path.exists(os.path.join(temp_dir, 'package.json'))

        # Run the Docker image in detached mode
        if is_python:
            port = '4567'
        elif is_node:
            port = '8000'
        else:
            raise ValueError("Unknown project type. Ensure it's a Python Flask or Node.js project.")

        EditorService._stop_container_on_port(port)

        cmd = ['docker', 'run', '--rm', '-d', '-p', f"{port}:{port}", image_name]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"Failed to run the app in Docker. Error: {result.stderr}")

        container_id = result.stdout.strip()

        time.sleep(1)

        access_url = f"http://localhost:{port}"

        return jsonify({"message": f"App is running. Access it at {access_url}. Container ID: {container_id}",
                        "url": access_url}), 200

    def clone_update_and_run_repo(self, repo_url, file_path, repo_name):
        temp_dir = f"/tmp/{repo_name}"
        image_name = f"{repo_name}"

        if not os.path.exists(temp_dir):
            self.run_repo(repo_url, repo_name)

        if not os.path.exists(file_path):
            return jsonify({'error': 'File not found after cloning'}), 404

        return self.update_and_run_repo(file_path, repo_name)

    @staticmethod
    def update_and_run_repo(file_path, repo_name):
        temp_dir = f"/tmp/{repo_name}"
        image_name = f"{repo_name}"

        start_time = time.time()

        if not os.path.exists(file_path):
            return jsonify({'error': 'File not found in local clone'}), 404

        try:
            # Copy the uploaded file to the temporary directory
            shutil.copy(file_path, os.path.join(temp_dir, os.path.basename(file_path)))

            is_python = os.path.exists(os.path.join(temp_dir, 'requirements.txt'))
            is_node = os.path.exists(os.path.join(temp_dir, 'package.json'))

            # Identify project type and its corresponding port
            if is_python:
                port = '4567'
            elif is_node:
                port = '8000'
            else:
                raise ValueError("Unknown project type. Ensure it's a Python Flask or Node.js project.")

            # Stop any container running on the target port
            EditorService._stop_container_on_port(port)

            cmd = ['docker', 'run', '--rm', '-d', '-p', f"{port}:{port}", '-v', f"{temp_dir}:/app", image_name]
            run_result = subprocess.run(cmd, capture_output=True, text=True, check=True)

            container_id = run_result.stdout.strip()
            access_url = f"http://localhost:{port}"

            return jsonify({"message": f"App is running. Access it at {access_url}. Container ID: {container_id}",
                            "url": access_url}), 200
        except subprocess.CalledProcessError as e:
            error_message = f"Error running Docker command: {e.stderr}"
            return jsonify({'error': error_message}), 500
        except Exception as e:
            error_message = f"An error occurred: {str(e)}"
            return jsonify({'error': error_message}), 500

    @staticmethod
    def does_docker_image_exist(image_name):
        cmd = ['docker', 'image', 'inspect', image_name]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

    @staticmethod
    def _stop_container_on_port(port):
        cmd = ['docker', 'ps', '-q', '--filter', f"publish={port}"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        container_id = result.stdout.strip()
        if container_id:
            subprocess.run(['docker', 'stop', '-t', '0', container_id])


editor_service = EditorService()


@app.route('/run', methods=['POST'])
def run_endpoint():
    data = request.json
    repo_url = data.get('repo_url')

    if not repo_url:
        return jsonify({'error': 'Repo URL is required'}), 400

    try:
        result = editor_service.run_repo(repo_url)
        return jsonify({"message": result})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/update-and-run', methods=['POST'])
def update_and_run_endpoint():
    try:
        # Check if the 'file' field exists in the POST request
        if 'file' not in request.files:
            return jsonify({'error': 'File not found in the request'}), 400

        # Get the uploaded file
        uploaded_file = request.files['file']

        # Check if the file has a name and is not empty
        if uploaded_file.filename == '' or not uploaded_file:
            return jsonify({'error': 'File name and file data are required'}), 400

        # Save the uploaded file to a temporary directory
        file_path = os.path.join("/tmp", uploaded_file.filename)
        uploaded_file.save(file_path)

        result = editor_service.update_and_run_repo(file_path)

        return jsonify({"message": result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/clone-update-and-run', methods=['POST'])
def clone_update_and_run_endpoint():
    try:
        data = request.form
        repo_url = data.get('repo_url')
        repo_name = data.get('repo_name')

        if 'file' not in request.files:
            return jsonify({'error': 'File not found in the request'}), 400

        uploaded_file = request.files['file']

        if uploaded_file.filename == '' or not uploaded_file:
            return jsonify({'error': 'File name and file data are required'}), 400

        file_path = os.path.join("/tmp", uploaded_file.filename)
        uploaded_file.save(file_path)

        result = editor_service.clone_update_and_run_repo(repo_url, file_path, repo_name)

        return jsonify({"message": result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health', methods=['GET'])
def index():
    return jsonify({'message': 'Yay, it is working and running fine !'})


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=7654)
