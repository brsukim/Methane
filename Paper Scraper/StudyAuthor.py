import os
import re
import PyPDF2

directory = 'TheFolder'
for filename in os.listdir(directory):
    if filename.endswith('.pdf'):
        # Open the PDF file
        with open(os.path.join(directory, filename), 'rb') as f:
            # Create a PDF object
            pdf = PyPDF2.PdfReader(f)
            # Split the file path into a head and tail
            head, tail = os.path.split(filename)
            # Extract the file name (the tail) from the split result
            pdf_name = tail
            # Collect string until first digit is found
            author_match = re.search(r'([^0-9]*)(?=\d|$)', pdf_name)
            if len(author_match.group(1)[:-1]) >= 15:
                # If string is >= 15, there is a chance the name was cut off
                print('***NAME IS TOO LONG. ENTER MANUALLY***')
            elif author_match:
                # Print the author if it was found
                print(author_match.group(1)[:-1])
            else:
                # Print "unknown" if the author was not found
                print('unknown')
           