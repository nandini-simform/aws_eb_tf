from flask import Flask

application = Flask(__name__) # This is the key: the instance must be named 'application'

@application.route('/')
def hello_world():
    return 'Hello from Flask on Elastic Beanstalk!'

if __name__ == '__main__':
    application.run(debug=True)
