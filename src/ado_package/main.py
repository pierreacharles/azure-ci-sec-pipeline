# script.py
import os
import sys

def main():
    print("🚀 Python script started successfully in Azure Pipelines!")
    
    # Example: Accessing system environment variables
    agent_name = os.getenv('AGENT_NAME', 'Unknown Agent')
    print(f"🤖 Running on build agent: {agent_name}")
    
    # Example: Simple calculation log
    num_list = [10, 20, 30, 40]
    total = sum(num_list)
    print(f"📊 The sum of the list {num_list} is: {total}")
    
    print("✅ Script execution completed.")

if __name__ == "__main__":
    main()

    # Example: Decorator Function Defines Wrapper and Function calls MyDecorator
def my_decorator(func):
    def wrapper():
        print("Something is happening before the function is called.")
        func()
        print("Something is happening after the function is called.")
        func()
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")
