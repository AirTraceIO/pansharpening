from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process():
    # Parse JSON data from request
    data = request.json
    arg1 = data.get('arg1')
    arg2 = data.get('arg2')
    arg3 = data.get('arg3')
    arg4 = data.get('arg4')

    # Check if all arguments are provided
    if not all([arg1, arg2, arg3, arg4]):
        return jsonify({"error": "Missing arguments, please provide all four arguments."}), 400

    # Prepare the command to execute the OTB script
    command = ["/otb/otb.sh", arg1, arg2, arg3, arg4]

    # Run the command
    try:
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return jsonify({"message": "Process completed successfully", "output": result.stdout.decode()}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": "Error processing the OTB script", "details": e.stderr.decode()}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
