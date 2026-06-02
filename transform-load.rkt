#lang racket/base

(require db
         gregor
         json
         racket/cmdline
         racket/port
         racket/sequence
         racket/string)

(struct sector-industry
  (sector
   industry)
  #:transparent)

(define base-folder (make-parameter "/var/local/vanguard/etf-holdings"))

(define folder-date (make-parameter (today)))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket transform-load.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "Vanguard ETF Holdings base folder. Defaults to /var/local/vanguard/etf-holdings"
                         (base-folder folder)]
 [("-d" "--folder-date") date
                         "Vanguard ETF Holdings folder date. Defaults to today"
                         (folder-date (iso8601->date date))]
 [("-n" "--db-name") name
                     "Database name. Defaults to 'local'"
                     (db-name name)]
 [("-p" "--db-pass") password
                     "Database password"
                     (db-pass password)]
 [("-u" "--db-user") user
                     "Database user name. Defaults to 'user'"
                     (db-user user)])

(define dbc (postgresql-connect #:user (db-user) #:database (db-name) #:password (db-pass)))

(define sub-industry-map
  (hash "Oil & Gas Drilling"
        (sector-industry "Energy" "Energy Equipment & Services")
        "Oil & Gas Equipment & Services"
        (sector-industry "Energy" "Energy Equipment & Services")
        "Integrated Oil & Gas"
        (sector-industry "Energy" "Oil, Gas & Consumable Fuels")
        "Oil & Gas Exploration & Production"
        (sector-industry "Energy" "Oil, Gas & Consumable Fuels")
        "Oil & Gas Refining & Marketing"
        (sector-industry "Energy" "Oil, Gas & Consumable Fuels")
        "Oil & Gas Storage & Transportation"
        (sector-industry "Energy" "Oil, Gas & Consumable Fuels")
        "Coal & Consumable Fuels"
        (sector-industry "Energy" "Oil, Gas & Consumable Fuels")

        "Commodity Chemicals"
        (sector-industry "Materials" "Chemicals")
        "Diversified Chemicals"
        (sector-industry "Materials" "Chemicals")
        "Fertilizers & Agricultural Chemicals"
        (sector-industry "Materials" "Chemicals")
        "Industrial Gases"
        (sector-industry "Materials" "Chemicals")
        "Specialty Chemicals"
        (sector-industry "Materials" "Chemicals")
        "Construction Materials"
        (sector-industry "Materials" "Construction Materials")
        "Metal, Glass & Plastic Containers"
        (sector-industry "Materials" "Containers & Packaging")
        "Paper & Plastic Packaging Products & Materials"
        (sector-industry "Materials" "Containers & Packaging")
        "Aluminum"
        (sector-industry "Materials" "Metals & Mining")
        "Diversified Metals & Mining"
        (sector-industry "Materials" "Metals & Mining")
        "Copper"
        (sector-industry "Materials" "Metals & Mining")
        "Gold"
        (sector-industry "Materials" "Metals & Mining")
        "Precious Metals & Minerals"
        (sector-industry "Materials" "Metals & Mining")
        "Silver"
        (sector-industry "Materials" "Metals & Mining")
        "Steel"
        (sector-industry "Materials" "Metals & Mining")
        "Forest Products"
        (sector-industry "Materials" "Paper & Forest Products")
        "Paper Products"
        (sector-industry "Materials" "Paper & Forest Products")

        "Aerospace & Defense"
        (sector-industry "Industrials" "Aerospace & Defense")
        "Building Products"
        (sector-industry "Industrials" "Building Products")
        "Construction & Engineering"
        (sector-industry "Industrials" "Construction & Engineering")
        "Electrical Components & Equipment"
        (sector-industry "Industrials" "Electrical Equipment")
        "Heavy Electrical Equipment"
        (sector-industry "Industrials" "Electrical Equipment")
        "Industrial Conglomerates"
        (sector-industry "Industrials" "Industrial Conglomerates")
        "Construction Machinery & Heavy Transportation Equipment"
        (sector-industry "Industrials" "Machinery")
        "Agricultural & Farm Machinery"
        (sector-industry "Industrials" "Machinery")
        "Industrial Machinery & Supplies & Components"
        (sector-industry "Industrials" "Machinery")
        "Trading Companies & Distributors"
        (sector-industry "Industrials" "Trading Companies & Distributors")
        "Commercial Printing"
        (sector-industry "Industrials" "Commercial Services & Supplies")
        "Environmental & Facilities Services"
        (sector-industry "Industrials" "Commercial Services & Supplies")
        "Office Services & Supplies"
        (sector-industry "Industrials" "Commercial Services & Supplies")
        "Diversified Support Services"
        (sector-industry "Industrials" "Commercial Services & Supplies")
        "Security & Alarm Services"
        (sector-industry "Industrials" "Commercial Services & Supplies")
        "Human Resource & Employment Services"
        (sector-industry "Industrials" "Professional Services")
        "Research & Consulting Services"
        (sector-industry "Industrials" "Professional Services")
        "Data Processing & Outsourced Services"
        (sector-industry "Industrials" "Professional Services")
        "Air Freight & Logistics"
        (sector-industry "Industrials" "Air Freight & Logistics")
        "Passenger Airlines"
        (sector-industry "Industrials" "Passenger Airlines")
        "Marine Transportation"
        (sector-industry "Industrials" "Marine Transportation")
        "Rail Transportation"
        (sector-industry "Industrials" "Ground Transportation")
        "Cargo Ground Transportation"
        (sector-industry "Industrials" "Ground Transportation")
        "Passenger Ground Transportation"
        (sector-industry "Industrials" "Ground Transportation")
        "Airport Services"
        (sector-industry "Industrials" "Transportation Infrastructure")
        "Highways & Railtracks"
        (sector-industry "Industrials" "Transportation Infrastructure")
        "Marine Ports & Services"
        (sector-industry "Industrials" "Transportation Infrastructure")
        
        "Automotive Parts & Equipment"
        (sector-industry "Consumer Discretionary" "Automobile Components")
        "Tires & Rubber"
        (sector-industry "Consumer Discretionary" "Automobile Components")
        "Automobile Manufacturers"
        (sector-industry "Consumer Discretionary" "Automobiles")
        "Motorcycle Manufacturers"
        (sector-industry "Consumer Discretionary" "Automobiles")
        "Consumer Electronics"
        (sector-industry "Consumer Discretionary" "Household Durables")
        "Home Furnishings"
        (sector-industry "Consumer Discretionary" "Household Durables")
        "Homebuilding"
        (sector-industry "Consumer Discretionary" "Household Durables")
        "Household Appliances"
        (sector-industry "Consumer Discretionary" "Household Durables")
        "Housewares & Specialties"
        (sector-industry "Consumer Discretionary" "Household Durables")
        "Leisure Products"
        (sector-industry "Consumer Discretionary" "Leisure Products")
        "Apparel, Accessories & Luxury Goods"
        (sector-industry "Consumer Discretionary" "Textiles, Apparel & Luxury Goods")
        "Footwear"
        (sector-industry "Consumer Discretionary" "Textiles, Apparel & Luxury Goods")
        "Textiles"
        (sector-industry "Consumer Discretionary" "Textiles, Apparel & Luxury Goods")
        "Casinos & Gaming"
        (sector-industry "Consumer Discretionary" "Hotels, Restaurants & Leisure")
        "Hotels, Resorts & Cruise Lines"
        (sector-industry "Consumer Discretionary" "Hotels, Restaurants & Leisure")
        "Leisure Facilities"
        (sector-industry "Consumer Discretionary" "Hotels, Restaurants & Leisure")
        "Restaurants"
        (sector-industry "Consumer Discretionary" "Hotels, Restaurants & Leisure")
        "Education Services"
        (sector-industry "Consumer Discretionary" "Diversified Consumer Services")
        "Specialized Consumer Services"
        (sector-industry "Consumer Discretionary" "Diversified Consumer Services")
        "Distributors"
        (sector-industry "Consumer Discretionary" "Distributors")
        "Broadline Retail"
        (sector-industry "Consumer Discretionary" "Broadline Retail")
        "Apparel Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")
        "Computer & Electronics Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")
        "Home Improvement Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")
        "Other Specialty Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")
        "Automotive Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")
        "Homefurnishing Retail"
        (sector-industry "Consumer Discretionary" "Specialty Retail")

        "Drug Retail"
        (sector-industry "Consumer Staples" "Consumer Staples Distribution & Retail")
        "Food Distributors"
        (sector-industry "Consumer Staples" "Consumer Staples Distribution & Retail")
        "Food Retail"
        (sector-industry "Consumer Staples" "Consumer Staples Distribution & Retail")
        "Consumer Staples Merchandise Retail"
        (sector-industry "Consumer Staples" "Consumer Staples Distribution & Retail")
        "Brewers"
        (sector-industry "Consumer Staples" "Beverages")
        "Distillers & Vintners"
        (sector-industry "Consumer Staples" "Beverages")
        "Soft Drinks & Non-Alcoholic Beverages"
        (sector-industry "Consumer Staples" "Beverages")
        "Agricultural Products & Services"
        (sector-industry "Consumer Staples" "Food Products")
        "Packaged Foods & Meats"
        (sector-industry "Consumer Staples" "Food Products")
        "Tobacco"
        (sector-industry "Consumer Staples" "Tobacco")
        "Household Products"
        (sector-industry "Consumer Staples" "Household Products")
        "Personal Care Products"
        (sector-industry "Consumer Staples" "Personal Care Products")

        "Health Care Equipment"
        (sector-industry "Health Care" "Health Care Equipment & Supplies")
        "Health Care Supplies"
        (sector-industry "Health Care" "Health Care Equipment & Supplies")
        "Health Care Distributors"
        (sector-industry "Health Care" "Health Care Providers & Services")
        "Health Care Services"
        (sector-industry "Health Care" "Health Care Providers & Services")
        "Health Care Facilities"
        (sector-industry "Health Care" "Health Care Providers & Services")
        "Managed Health Care"
        (sector-industry "Health Care" "Health Care Providers & Services")
        "Health Care Technology"
        (sector-industry "Health Care" "Health Care Technology")
        "Biotechnology"
        (sector-industry "Health Care" "Biotechnology")
        "Pharmaceuticals"
        (sector-industry "Health Care" "Pharmaceuticals")
        "Life Sciences Tools & Services"
        (sector-industry "Health Care" "Life Sciences Tools & Services")

        "Diversified Banks"
        (sector-industry "Financials" "Banks")
        "Regional Banks"
        (sector-industry "Financials" "Banks")
        "Diversified Financial Services"
        (sector-industry "Financials" "Financial Services")
        "Multi-Sector Holdings"
        (sector-industry "Financials" "Financial Services")
        "Specialized Finance"
        (sector-industry "Financials" "Financial Services")
        "Commercial & Residential Mortgage Finance"
        (sector-industry "Financials" "Financial Services")
        "Transaction & Payment Processing Services"
        (sector-industry "Financials" "Financial Services")
        "Consumer Finance"
        (sector-industry "Financials" "Consumer Finance")
        "Asset Management & Custody Banks"
        (sector-industry "Financials" "Capital Markets")
        "Investment Banking & Brokerage"
        (sector-industry "Financials" "Capital Markets")
        "Diversified Capital Markets"
        (sector-industry "Financials" "Capital Markets")
        "Financial Exchanges & Data"
        (sector-industry "Financials" "Capital Markets")
        "Mortgage REITs"
        (sector-industry "Financials" "Mortgage Real Estate Investment Trusts (REITs)")
        "Insurance Brokers"
        (sector-industry "Financials" "Insurance")
        "Life & Health Insurance"
        (sector-industry "Financials" "Insurance")
        "Multi-Line Insurance"
        (sector-industry "Financials" "Insurance")
        "Property & Casualty Insurance"
        (sector-industry "Financials" "Insurance")
        "Reinsurance"
        (sector-industry "Financials" "Insurance")

        "IT Consulting & Other Services"
        (sector-industry "Information Technology" "IT Services")
        "Internet Services & Infrastructure"
        (sector-industry "Information Technology" "IT Services")
        "Application Software"
        (sector-industry "Information Technology" "Software")
        "Systems Software"
        (sector-industry "Information Technology" "Software")
        "Communications Equipment"
        (sector-industry "Information Technology" "Communications Equipment")
        "Technology Hardware, Storage & Peripherals"
        (sector-industry "Information Technology" "Technology Hardware, Storage & Peripherals")
        "Electronic Equipment & Instruments"
        (sector-industry "Information Technology" "Electronic Equipment, Instruments & Components")
        "Electronic Components"
        (sector-industry "Information Technology" "Electronic Equipment, Instruments & Components")
        "Electronic Manufacturing Services"
        (sector-industry "Information Technology" "Electronic Equipment, Instruments & Components")
        "Technology Distributors"
        (sector-industry "Information Technology" "Electronic Equipment, Instruments & Components")
        "Semiconductor Materials & Equipment"
        (sector-industry "Information Technology" "Semiconductors & Semiconductor Equipment")
        "Semiconductors"
        (sector-industry "Information Technology" "Semiconductors & Semiconductor Equipment")

        "Alternative Carriers"
        (sector-industry "Communication Services" "Diversified Telecommunication Services")
        "Integrated Telecommunication Services"
        (sector-industry "Communication Services" "Diversified Telecommunication Services")
        "Wireless Telecommunication Services"
        (sector-industry "Communication Services" "Wireless Telecommunication Services")
        "Advertising"
        (sector-industry "Communication Services" "Media")
        "Broadcasting"
        (sector-industry "Communication Services" "Media")
        "Cable & Satellite"
        (sector-industry "Communication Services" "Media")
        "Publishing"
        (sector-industry "Communication Services" "Media")
        "Movies & Entertainment"
        (sector-industry "Communication Services" "Entertainment")
        "Interactive Home Entertainment"
        (sector-industry "Communication Services" "Entertainment")
        "Interactive Media & Services"
        (sector-industry "Communication Services" "Interactive Media & Services")

        "Electric Utilities"
        (sector-industry "Utilities" "Electric Utilities")
        "Gas Utilities"
        (sector-industry "Utilities" "Gas Utilities")
        "Multi-Utilities"
        (sector-industry "Utilities" "Multi-Utilities")
        "Water Utilities"
        (sector-industry "Utilities" "Water Utilities")
        "Independent Power Producers & Energy Traders"
        (sector-industry "Utilities" "Independent Power & Renewable Electricity Producers")
        "Renewable Electricity"
        (sector-industry "Utilities" "Independent Power & Renewable Electricity Producers")

        "Diversified REITs"
        (sector-industry "Real Estate" "Diversified REITs")
        "Industrial REITs"
        (sector-industry "Real Estate" "Industrial REITs")
        "Hotel & Resort REITs"
        (sector-industry "Real Estate" "Hotel & Resort REITs")
        "Office REITs"
        (sector-industry "Real Estate" "Office REITs")
        "Health Care REITs"
        (sector-industry "Real Estate" "Health Care REITs")
        "Multi-Family Residential REITs"
        (sector-industry "Real Estate" "Residential REITs")
        "Single-Family Residential REITs"
        (sector-industry "Real Estate" "Residential REITs")
        "Retail REITs"
        (sector-industry "Real Estate" "Retail REITs")
        "Other Specialized REITs"
        (sector-industry "Real Estate" "Specialized REITs")
        "Self-Storage REITs"
        (sector-industry "Real Estate" "Specialized REITs")
        "Telecom Tower REITs"
        (sector-industry "Real Estate" "Specialized REITs")
        "Timber REITs"
        (sector-industry "Real Estate" "Specialized REITs")
        "Data Center REITs"
        (sector-industry "Real Estate" "Specialized REITs")
        "Diversified Real Estate Activities"
        (sector-industry "Real Estate" "Real Estate Management & Development")
        "Real Estate Operating Companies"
        (sector-industry "Real Estate" "Real Estate Management & Development")
        "Real Estate Development"
        (sector-industry "Real Estate" "Real Estate Management & Development")
        "Real Estate Services"
        (sector-industry "Real Estate" "Real Estate Management & Development")
        ))

(parameterize ([current-directory (string-append (base-folder) "/" (~t (folder-date) "yyyy-MM-dd") "/")])  
  (for ([p (sequence-filter (λ (p) (string-contains? (path->string p) ".json")) (in-directory (current-directory)))])
    (let* ([file-name (path->string p)]
           [ticker-symbol (string-replace (string-replace file-name (path->string (current-directory)) "") ".json" "")])
      (call-with-input-file file-name
        (λ (in)
          (displayln file-name)
          (let ([holdings (hash-ref (string->jsexpr (port->string in)) 'holding)])
            (define insert-counter 0)
            (define insert-success-counter 0)
            (define insert-failure-counter 0)
            (for-each (λ (holding)
                        (set! insert-counter (add1 insert-counter))
                        (with-handlers ([exn:fail? (λ (e) (displayln (string-append "Failed to process component "
                                                                                    (hash-ref holding 'ticker)
                                                                                    " for ETF "
                                                                                    ticker-symbol
                                                                                    " on date "
                                                                                    (date->iso8601 (folder-date))))
                                                     (displayln e)
                                                     (rollback-transaction dbc)
                                                     (set! insert-failure-counter (add1 insert-failure-counter)))])
                          (start-transaction dbc)
                          (define sub-industry
                            (cond [(equal? "Commercial & Residential Mortgage Financ" (hash-ref holding 'sector)) "Commercial & Residential Mortgage Finance"]
                                  [(equal? "Construction Machinery & Heavy Transport" (hash-ref holding 'sector)) "Construction Machinery & Heavy Transportation Equipment"]
                                  [(equal? "Technology Hardware, Storage & Periphera" (hash-ref holding 'sector)) "Technology Hardware, Storage & Peripherals"]
                                  [(equal? "Data Center Reits" (hash-ref holding 'sector)) "Data Center REITs"]
                                  [(equal? "Diversified Reits" (hash-ref holding 'sector)) "Diversified REITs"]
                                  [(equal? "Health Care Reits" (hash-ref holding 'sector)) "Health Care REITs"]
                                  [(equal? "Hotel & Resort Reits" (hash-ref holding 'sector)) "Hotel & Resort REITs"]
                                  [(equal? "Independent Power Producers & Energy Tra" (hash-ref holding 'sector)) "Independent Power Producers & Energy Traders"]
                                  [(equal? "Industrial Machinery & Supplies & Compon" (hash-ref holding 'sector)) "Industrial Machinery & Supplies & Components"]
                                  [(equal? "Industrial Reits" (hash-ref holding 'sector)) "Industrial REITs"]
                                  [(equal? "It Consulting & Other Services" (hash-ref holding 'sector)) "IT Consulting & Other Services"]
                                  [(equal? "Mortgage Reits" (hash-ref holding 'sector)) "Mortgage REITs"]
                                  [(equal? "Multi-Family Residential Reits" (hash-ref holding 'sector)) "Multi-Family Residential REITs"]
                                  [(equal? "Office Reits" (hash-ref holding 'sector)) "Office REITs"]
                                  [(equal? "Other Specialized Reits" (hash-ref holding 'sector)) "Other Specialized REITs"]
                                  [(equal? "Paper & Plastic Packaging Products & Mat" (hash-ref holding 'sector)) "Paper & Plastic Packaging Products & Materials"]
                                  [(equal? "Retail Reits" (hash-ref holding 'sector)) "Retail REITs"]
                                  [(equal? "Self-Storage Reits" (hash-ref holding 'sector)) "Self-Storage REITs"]
                                  [(equal? "Single-Family Residential Reits" (hash-ref holding 'sector)) "Single-Family Residential REITs"]
                                  [(equal? "Telecom Tower Reits" (hash-ref holding 'sector)) "Telecom Tower REITs"]
                                  [(equal? "Timber Reits" (hash-ref holding 'sector)) "Timber REITs"]
                                  [(equal? "Transaction & Payment Processing Service" (hash-ref holding 'sector)) "Transaction & Payment Processing Services"]
                                  [else (hash-ref holding 'sector)]))
                          (query-exec dbc "
update spdr.etf_holding
set
  sector = $3::text::spdr.sector,
  industry = $4::text::spdr.industry,
  sub_industry = $5::text::spdr.sub_industry
where
  date = $1::text::date and
  component_symbol = $2;
"
                                      (~t (folder-date) "yyyy-MM-dd")
                                      (hash-ref holding 'ticker)
                                      (sector-industry-sector (hash-ref sub-industry-map sub-industry))
                                      (sector-industry-industry (hash-ref sub-industry-map sub-industry))
                                      sub-industry)
                          (commit-transaction dbc)
                          (set! insert-success-counter (add1 insert-success-counter)))) holdings)
            (displayln (string-append "Attempted to update " (number->string insert-counter) " rows. "
                                      (number->string insert-success-counter) " were successful. "
                                      (number->string insert-failure-counter) " failed."))))))))

(disconnect dbc)
