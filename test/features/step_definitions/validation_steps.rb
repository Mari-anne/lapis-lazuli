################################################################################
# Copyright 2014 spriteCloud B.V. All rights reserved.
# Generated by LapisLazuli, version 0.0.1
# Author: "Onno Steenbergen" <onno@steenbe.nl>

require 'test/unit/assertions'

include Test::Unit::Assertions

Then(/(first|last|random|[0-9]+[a-z]+) (.*) should (not )?be the (first|last|[0-9]+[a-z]+) element on the page$/) do |index, type, differ, location_on_page|
	# Convert the type text to a symbol
	type = type.downcase.gsub(" ","_")

	pick = 0
	if ["first","last","random"].include?(index)
		pick = index.to_sym
	else
		pick = index.to_i - 1
	end
	# Options for find
	options = {}
	# Select the correct element
	options[type.to_sym] = {}
	# Pick the correct one
	options[:pick] = pick
	# Execute the find
	type_element = browser.find(options)

	# All elements on the page
	body_elements = browser.body.elements
	# Find the element we need
	page_element = nil
	if location_on_page == "first"
		page_element = body_elements.first
	elsif location_on_page == "last"
		page_element = body_elements.last
	else
		page_element = body_elements[location_on_page.to_i - 1]
	end

	# No page element
	if not page_element
		error("Could not find an element on the page")
	# Elements are the same but it should not be
	elsif page_element == type_element and differ
		error("Elements on the page are the same")
	# Elements are different but should be the same
	elsif page_element != type_element and not differ
		error("Elements should be the same")
	end
end

Then(/(first|last|random|[0-9]+[a-z]+) (.*) should (not )?be present$/) do |index, type, hidden|
  # Convert the type text to a symbol
	type = type.downcase.gsub(" ","_")

	pick = 0
	if ["first","last","random"].include?(index)
		pick = index.to_sym
	else
		pick = index.to_i - 1
	end

	# Options for find_all
  options = {}
	# Select the correct element
	options[type.to_sym] = {}
	# Pick the correct one
	options[:pick] = pick
	# Execute the find
	type_element = browser.find(options)
	# Find all
	all_elements = browser.find_all(options)

  options[:filter_by] = :present?
	all_present = browser.find_all(options)

	if hidden and type_element.present?
		error("Hidden element is visible")
	elsif not hidden and not type_element.present?
		error("Element is hidden")
	elsif hidden and not type_element.present? and
		(not all_elements.include?(type_element) or all_present.include?(type_element))
		error("Hidden element (not) found via find_all(:filter_by => :present?)")
	elsif not hidden and type_element.present? and
		(not all_elements.include?(type_element) or not all_present.include?(type_element))
		error("Visible element (not) found via find_all(:filter_by => :present?)")
	end
end

Then(/^within (\d+) seconds I should see "([^"]+?)"( disappear)?$/) do |timeout, text, condition|
  if condition
		condition = :while
	else
		condition = :until
	end

	browser.wait(
		:timeout => timeout,
		:text => text,
		:condition => condition,
		:groups => ["wait"]
	)
end

Then(/^within (\d+) seconds I should see "([^"]+?)" and "([^"]+?)"( disappear)?$/) do |timeout, first, second, condition|
	if condition
		condition = :while
	else
		condition = :until
	end

	browser.multi_wait_all(
		:timeout => timeout,
		:condition => condition,
		:mode => :match_all,
		:groups => ["wait"],
		:selectors => [
			{ :tag_name => 'span', :class => /foo/ },
			{ :tag_name => 'div', :id => 'bar' }
		]
	)
end

Then(/^within (\d+) seconds I should see added elements with matching$/) do |timeout|
	elems = browser.multi_wait_all(
		:timeout => timeout,
		:condition => :until,
		:mode => :match_all,
		:groups => ["wait"],
		:selectors => [
			{ :tag_name => 'span', :class => /foo/, :text => /foo/ },
			{ :tag_name => 'div', :id => 'bar', :html => "bar" }
		]
	)
 	assert (2 == elems.length), "Expected two elements, found #{elems.length}"
end

Then(/^within 10 seconds I should see either added element/) do
	browser.multi_wait_all(
			{ :tag_name => 'a', :class => /foo/ },
			{ :tag_name => 'div', :id => 'bar' }
	)
end

Then(/^within (\d+) seconds I get an error waiting for "(.*?)"( disappear)?$/) do |timeout, text, condition|
	if condition
		condition = :while
	else
		condition = :until
	end

	begin
		browser.wait(
			:timeout => timeout,
			:text => text,
			:condition => condition,
			:screenshot => true,
			:groups => ["wait"]
		)
		error(
			:message => "Didn't receive an error with this timeout",
			:screenshot => true,
			:groups => ["wait"]
		)
	rescue StandardError => err
	end
end

Then(/^a screenshot should have been created$/) do
	# Check if there is a screenshot with the correct name
	name = browser.screenshot_name
	if Dir[name].empty?
		error(
			:message => "Didn't find a screenshot for this scenario: #{name}",
			:groups => ["screenshot"]
		)
	end
end

Then(/^I expect javascript errors$/) do
	errors = browser.get_js_errors
	if !errors.nil? and errors.length > 0
		scenario.check_browser_errors = false
	else
		error(
			:message => "No Javascript errors detected",
			:groups => ["error"]
		)
	end
end

Then(/^I expect a (\d+) status code$/) do |expected|
	expected = expected.to_i
	if browser.get_http_status == expected && expected > 299
		scenario.check_browser_errors = false
	elsif browser.get_http_status != expected
		error(
			:message => "Incorrect status code: #{browser.get_http_status}",
			:groups => ["error"]
		)
	end
end

Then(/^I expect (no|\d+) HTML errors?$/) do |expected|
	expected = expected.to_i
	scenario.check_browser_errors = false
	if browser.get_html_errors.length != expected
		error(
			:message => "Expected #{expected} errors: #{browser.get_html_errors}",
			:groups => ["error"]
		)
	end
end

Then(/^the firefox browser named "(.*?)" has a profile$/) do |name|
	if scenario.storage.has? name
		browser = scenario.storage.get name
		if browser.driver.capabilities.firefox_profile.nil?
			raise "Profile is not set"
		end
	else
		error("No item in the storage named #{name}")
	end
end

Then(/^I expect the "(.*?)" to exist$/) do |name|
	browser.find(name)
end

Then(/^I expect an? (.*?) element to exist$/) do |element|
	browser.find(element.to_sym)
end

Then(/^I expect to find an? (.*?) element with (.*?) "(.*?)" using (.*?) settings$/) do |element, attribute, text, setting_choice|
	settings = {
		"method" => {element.downcase => { attribute.to_sym => /#{text}/}},
		"like with hash" => {:like =>{
			:element => element.downcase,
			:attribute => attribute,
			:include => text
			}},
		"like with array" => {:like => [element.downcase, attribute, text]},
		"tag name" => {:tag_name => element.downcase, attribute.to_sym => /#{text}/}
	}
	setting = settings[setting_choice]
	# Find always throws an error if not found
	elem_find = browser.find(setting)
	elem_findall = browser.find_all(setting).first
	if elem_find != elem_findall
		error "Incorrect results"
	end
end

Then(/^I expect to find an? (.*?) element or an? (.*?) element$/) do |element1, element2|
	element = browser.multi_find(element1.to_sym, element2.to_sym)
end

Then(/^I should (not )?find "(.*?)" ([0-9]+ times )?using "(.*?)" as context$/) do |result, number, id, name|
	context = scenario.storage.get name
	if context.nil?
		error(:not_found => "Find context in storage")
	end
	begin
		settings = {:element => id, :context => context}
		if number == "a"
			element = browser.find(settings)
		else
			settings[:filter_by] = :present?
			elements = browser.find_all(settings)
			if elements.length != number.to_i
				error("Incorrect number of elements: #{elements.length}")
			end
		end
	rescue
		if result.nil?
			raise $!
		end
	end
end

Given(/^I generate and store an email$/) do
  x = variable("%{email}")
  storage.set("test_email", x)
end

Then(/^I can retrieve the email$/) do
  x = storage.get("test_email")
  assert !x.nil?, "Could not retrieve email from storage."
end

Then(/^I expect the email to contain the domain name I specified\.$/) do
  x = storage.get("test_email")
  domain = env_or_config('email_domain')
  assert x.include?(domain), "Generated email #{x} does not contain configured domain #{domain}!"
end


Given(/^I include a (world|browser) module$/) do |type|
  # Nothing to do - see features/support/env.rb
  true
end

Then(/^I expect the (world|browser) module's functions to be available$/) do |type|
  # We're essentially testing that NoMethodError is not being raised here.
  case type
  when "browser"
    browser.test_func
  when "world"
    test_func
  else
    raise "No such module type: #{type}"
  end
end

Given(/^I am in browser "(.*?)"$/) do |b_name|
  assert b_name == browser.browser_name, "Cannot reproduce issue outside of #{b_name}."
end


Then(/^I expect not to find "(.*?)"$/) do |id|
  element = browser.find(:id => id)
  assert element.nil?, "Found the some element!"
end
