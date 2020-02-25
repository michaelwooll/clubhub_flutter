import firebase_admin
from firebase_admin import credentials, firestore
import csv


cred = credentials.Certificate("./ServiceAccountKey.json")
default_app = firebase_admin.initialize_app(cred)

db = firestore.client()


CHICO_ID = "MzMsjEsaAIBTeWbcCsio"
TYPE = "Club"
EXCLUSIVE = False


with open('club_data.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count != 0:
            title = row[0]
            img = row[1]
            desc = row[2]
            if(title != "NA"):
                db.collection("club").document().set({
                    "campusID": unicode(CHICO_ID, "utf-8"),
                    "description": unicode(desc, "utf-8"),
                    "exclusive": EXCLUSIVE,
                    "name": unicode(title,"utf-8"),
                    "type": unicode(TYPE, "utf-8"),
                    "img_url" : unicode(img,"utf-8")
                })
        line_count += 1

