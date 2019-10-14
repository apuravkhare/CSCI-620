from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello World!'


@app.route('/getSample', methods=['GET'])
def get_test():
    return {
        'id': 1,
        'name': 'test'
    }


if __name__ == '__main__':
    app.run()
