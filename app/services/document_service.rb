require 'radish/documents/core'
require 'xa/ubl/invoice'

class DocumentService
  extend Radish::Documents::Core

  class Parser
    include XA::UBL::Invoice
  end

  def self.make_envelope(content)
    env = {}.tap do |o|
      sic = get(content, 'parties.supplier.industry_code', {})
      cic = get(content, 'parties.customer.industry_code', {})

      v = get(sic, 'value', nil)
      if get(sic, 'list.id', nil) == 'ISIC' && v
        o[:industry] = { supplier: v }
      end
      v = cic.fetch('value', nil)
      if get(cic, 'list.id', nil) == 'ISIC' && v
        o[:industry] = o[:industry].merge(customer: v)
      end

      sc = find_country(
        get(content, 'parties.supplier.location.address.country.code.value'),
        get(content, 'parties.supplier.location.address.country.name'))
      sc = find_country(
        get(content, 'parties.supplier.address.country.code.value'),
        get(content, 'parties.supplier.address.country.name')) if !sc
      ssek = find_subentity(
        get(content, 'parties.supplier.location.address.subentity.code.value'))
      ssek = find_subentity(
        get(content, 'parties.supplier.location.address.subentity.name')) if !ssek
      ssek = find_subentity_by_name(
        sc,
        get(content, 'parties.supplier.location.address.subentity.name')) if !ssek
      ssek = find_subentity(
        get(content, 'parties.supplier.address.subentity.code.value')) if !ssek
      ssek = find_subentity(
        get(content, 'parties.supplier.address.subentity.name')) if !ssek
      ssek = find_subentity_by_name(
        sc,
        get(content, 'parties.supplier.address.subentity.name')) if !ssek

      sloc = { country: sc.alpha2 } if sc
      sloc = (sloc || {}).merge(subentity: ssek) if ssek
      
      cc = find_country(
        get(content, 'parties.customer.location.address.country.code.value'),
        get(content, 'parties.customer.location.address.country.name'))
      cc = find_country(
        get(content, 'parties.customer.address.country.code.value'),
        get(content, 'parties.customer.address.country.name')) if !cc
      csek = find_subentity(
        get(content, 'parties.customer.location.address.subentity.code.value'))
      csek = find_subentity(
        get(content, 'parties.customer.location.address.subentity.name')) if !csek
      csek = find_subentity_by_name(
        cc,
        get(content, 'parties.customer.location.address.subentity.name')) if !csek
      csek = find_subentity(
        get(content, 'parties.customer.address.subentity.code.value')) if !csek
      csek = find_subentity(
        get(content, 'parties.customer.address.subentity.name')) if !csek
      csek = find_subentity_by_name(
        cc,
        get(content, 'parties.customer.address.subentity.name')) if !csek

      cloc = { country: cc.alpha2 } if cc
      cloc = (cloc || {}).merge(subentity: csek) if csek

      locations = { supplier: sloc } if sloc
      locations = locations.merge({ customer: cloc }) if cloc
      
      o[:locations] = locations if locations
    end
  end
  
  def self.created(id)
    dm = Document.find(id)
    if dm
      Parser.new.parse(dm.src) do |content|
        # extract the envelope
        content = content.with_indifferent_access

        dm.update_attributes(content: content, envelope: make_envelope(content))
      end

      QueueService.document_created(id)
    end
  end

  private

  def self.find_country(code, name)
    c = ISO3166::Country.new(code) || ISO3166::Country.new(name)
    if !c
      found = ISO3166::Country.find_by_alpha3(name)
      c = ISO3166::Country.new(found.first) if found
    end
    if !c
      found = ISO3166::Country.find_by_name(name)
      c = ISO3166::Country.new(found.first) if found
    end
    c
  end

  def self.find_subentity(code)
    rv = nil

    if code
      (country, *sec) = code.split('-')
      sec = sec.join('-')
      c = ISO3166::Country.new(country)
      rv = sec if c && c.subdivisions.key?(sec)
    end

    rv
  end

  def self.find_subentity_by_name(c, name)
    rv = nil

    if c && name
      rv = c.subdivisions.keys.select { |k| c.subdivisions[k].name == name }.first
    end

    rv
  end
end
