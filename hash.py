import hashlib
import base64

def verify_password(stored_hash, provided_password):
    iterations, salt, stored_key = stored_hash.split('$')
    iterations = int(iterations)
    salt = base64.b64decode(salt)
    stored_key = base64.b64decode(stored_key)
    
    provided_key = hashlib.pbkdf2_hmac('sha256', 
                                       provided_password.encode(), 
                                       salt, 
                                       iterations)
    
    return provided_key == stored_key

# Example usage
stored_hash = '100000$848pWSNvULBJtROVtJ8VzY4Z7wEYkfa4dd9LOyge/oi7h0QCx4jLafjn9G4tmeN7PqeHWziCebOKJthL2QO2FA=='
password = 'your-password-here'

if verify_password(stored_hash, password):
    print("Password is correct")
else:
    print("Password is incorrect")
