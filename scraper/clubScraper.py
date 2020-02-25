from selenium.webdriver import Chrome
import pandas as pd
import time
import csv
import datetime

NUM_CLICKS = 23

start = datetime.datetime.now()
time.sleep(2)

#open csv file
clubCSV = open('club_data.csv', mode = 'w')
clubWriter = csv.writer(clubCSV, delimiter = ',')
clubWriter.writerow(['Name', 'img', 'description'])


webdriver = "./chromedriver"

driver = Chrome(webdriver)

url = "https://csuchico.campuslabs.com/engage/organizations"

driver.get(url)
time.sleep(2)

loadMore = driver.find_elements_by_class_name("outlinedButton")[1].find_element_by_tag_name("button")

# Load all clubs onto page
for i in range(NUM_CLICKS):
	loadMore.click()
	time.sleep(1)

orglist = driver.find_element_by_id("org-search-results")
clubLinkElements = orglist.find_elements_by_tag_name("a")
links = []

for item in clubLinkElements:
	links.append(item.get_attribute('href'))
print("Going through " + str(len(links)) + " clubs.")
count = 1
for url in links:
	print("Club " + str(count) + " with URL: " + url)
	#Open url
	driver.get(url)
	#Wait to load
	time.sleep(2)
	#Get needed information for each club
	#Get desc
	try:
		descriptionDiv = driver.find_element_by_class_name("userSupplied")
		description = descriptionDiv.find_element_by_tag_name("p").text.encode("utf8")
	except:
		description = "NA"

	#get img and title
	try:
		parentDiv = descriptionDiv.find_element_by_xpath('..')
		title = parentDiv.find_element_by_tag_name("h1").text.encode("utf8")
		img = parentDiv.find_element_by_tag_name("img")
		img_src = img.get_attribute("src")
	except:
		img_src = "NA"
		title = "NA"

	# write to CSV
	clubWriter.writerow([title,img_src,description])
	print("Club " + str(count) + " written.")
	count+=1

end = datetime.datetime.now()
total = end - start

print("Done!")

print("Total time taken in HOURS:MINUTES:SECONDS format")
print(total)
