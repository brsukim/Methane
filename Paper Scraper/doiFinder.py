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
            # Extract the text from the page
            text = pdf.pages[0].extract_text()
            # Use a regular expression to search for the doi pattern
            doi = ''
            for i in range(len(text)):
                if text[i].lower() == "d" and text[i+1].lower() == "o" and text[i+2].lower() == "i" and text[i+3] == ":":
                    if (text[i+4] == " "):
                        i = i + 1
                    for j in range(i+4, len(text)):
                        if (not text[j].isdigit() and not text[j].isalpha() and text[j] != "/" and text[j] != "." and text[j] != "-"):
                            break
                        else:
                            doi += text[j]
                    print(doi)
                    break
                elif text[i].lower() == "d" and text[i+1].lower() == "o" and text[i+2].lower() == "i" and text[i+3] == "/":
                    if (text[i+4] == " "):
                        i = i + 1
                    for j in range(i+4, len(text)):
                        
                        if (not text[j].isdigit() and not text[j].isalpha() and text[j] != "/" and text[j] != "." and text[j] != "-"):
                            break
                        else:
                            doi += text[j]
                    print(doi)
                    break
                elif text[i] == "D" and text[i+1] == "O" and text[i+2] == "I" and text[i+3] == " ":
                    for j in range(i+4, len(text)):
                        if (not text[j].isdigit() and not text[j].isalpha() and text[j] != "/" and text[j] != "." and text[j] != "-"):
                            break
                        else:
                            doi += text[j]
                    print(doi)
                    break
                elif text[i] == "d" and text[i+1] == "o" and text[i+2] == "i" and text[i+3] == "." and text[i+4] == "o" and text[i+5] == "r":
                    for j in range(i+8, len(text)):
                        if (not text[j].isdigit() and not text[j].isalpha() and text[j] != "/" and text[j] != "." and text[j] != "-"):
                            break
                        else:
                            doi += text[j]
                    print(doi)
                    break
            if (doi == ''):
                print('idk')
    