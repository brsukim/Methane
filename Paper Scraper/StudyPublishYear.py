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
            year_pattern = r'\b\d{4}\b'
            year_match = re.search(year_pattern, pdf_name)
            if year_match:
                # Print the year if it was found
                year = year_match.group(0)
                print(year)
            else:
                # Print "unknown" if the year was not found
                print('unknown')