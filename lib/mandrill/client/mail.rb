module Mandrill
    module Client
        using Refinements if Client.ruby_version21?

        class MailError < Error
            attr_reader :errors

            def initialize(errors)
                super(errors)
            end
        end

        class Mail
            include Commons
            EMAIL_FMT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

            attr_reader :errors, :html, :subject, :from_email, :to, :text, :from_name, :headers
            attr_reader :important, :track_opens, :track_clicks, :auto_text, :auto_html, :inline_css
            attr_reader :url_strip_qs, :preserve_recipients, :view_content_link, :bcc_address, :tracking_domain
            attr_reader :signing_domain, :return_path_domain, :merge, :global_merge_vars, :merge_vars, :tags
            attr_reader :subaccount, :google_analytics_domains, :google_analytics_campaign, :metadata
            attr_reader :recipient_metadata, :attachments, :images

            def errors_to_s errors
                str = "Mail is invalid:"
                errors.each do |error|
                    str += "\n\t#{error}"
                end
                str
            end

            def initialize(args = {})
                @errors = []

                @html = args[:html].to_s || add_missing_field(:html)
                @subject = args[:subject].to_s || add_missing_field(:subject)
                @from_email = check_format(args[:from_email].to_s, EMAIL_FMT, :email) || add_missing_field(:from_email)
                @to = check_type(args[:to], Array, :to) || add_missing_field(:to)

                @text = args[:text] unless args[:text].blank?
                @from_name = args[:from_name] unless args[:from_name].blank?
                @headers = args[:headers] unless args[:headers].blank? || !args[:headers].is_a?(Hash)
                @important = args[:important] unless args[:important].nil? || !Client.boolean?(args[:important])
                @track_opens = args[:track_opens] unless args[:track_opens].nil? || !Client.boolean?(args[:track_opens])
                @track_clicks = args[:track_clicks] unless args[:track_clicks].nil? || !Client.boolean?(args[:track_clicks])
                @auto_text = args[:auto_text] unless args[:auto_text].nil? || !Client.boolean?(args[:auto_text])
                @auto_html = args[:auto_html] unless args[:auto_html].nil? || !Client.boolean?(args[:auto_html])
                @inline_css = args[:inline_css] unless args[:inline_css].nil? || !Client.boolean?(args[:inline_css])
                @url_strip_qs = args[:url_strip_qs] unless args[:url_strip_qs].nil? || !Client.boolean?(args[:url_strip_qs])
                @preserve_recipients = args[:preserve_recipients] unless args[:preserve_recipients].nil? || !Client.boolean?(args[:preserve_recipients])
                @view_content_link = args[:view_content_link] unless args[:view_content_link].nil? || !Client.boolean?(args[:view_content_link])
                @bcc_address = args[:bcc_address] unless args[:bcc_address].blank?
                @tracking_domain = args[:tracking_domain] unless args[:tracking_domain].blank?
                @signing_domain = args[:signing_domain] unless args[:signing_domain].blank?
                @return_path_domain = args[:return_path_domain] unless args[:return_path_domain].blank?
                @merge = args[:merge] unless args[:merge].nil? || !Client.boolean?(args[:merge])
                @global_merge_vars = check_type(args[:global_merge_vars], Array, :global_merge_vars) unless args[:global_merge_vars].blank?
                @merge_vars = check_type(args[:merge_vars], Array, :merge_vars) unless args[:merge_vars].blank?
                @tags = check_type(args[:tags], Array, :tags) unless args[:tags].blank?
                @subaccount = args[:subaccount] unless args[:subaccount].blank?
                @google_analytics_domains = check_type(args[:google_analytics_domains], Array, :google_analytics_domains) unless args[:google_analytics_domains].blank?
                @google_analytics_campaign = args[:google_analytics_campaign] unless args[:google_analytics_campaign].blank?
                @metadata = check_type(args[:metadata], Hash, :metadata) unless args[:metadata].blank?
                @recipient_metadata = check_type(args[:recipient_metadata], Array, :recipient_metadata) unless args[:recipient_metadata].blank?
                @attachments = check_type(args[:attachments], Array, :attachments) unless args[:attachments].blank?
                @images = check_type(args[:images], Array, :attachments) unless args[:images].blank?

                check_recipients unless @to.nil?
                check_global_merge_vars unless @global_merge_vars.nil?
                check_merge_vars unless @merge_vars.nil?
                check_tags unless @tags.nil?
                check_google_analytics_domains unless @google_analytics_domains.nil?
                check_metadata unless @metadata.nil?
                check_recipient_metadata unless @recipient_metadata.nil?
                check_attachments unless @attachments.nil?
                check_images unless @images.nil?

                if @errors.blank?
                    remove_instance_variable :@errors
                else
                    raise MailError, errors_to_s(@errors)
                end
            end

            def add_missing_field(field)
                @errors << "#{field} is missing"
                nil
            end

            def check_format(str, fmt, str_name = nil)
                if (fmt =~ str).nil?
                    err_msg = "#{str} doesn't match required format #{fmt}"
                    err_msg = "#{str_name} doesn't match required format #{fmt}" if str_name
                    @errors << err_msg
                    return nil
                end
                str
            end

            def check_type(obj, type, obj_name = nil)
                unless obj.is_a? type
                    err_msg = "\"#{obj}\" hasn't required type (#{type})"
                    err_msg = "#{obj_name} hasn't required type (#{type})" if obj_name
                    @errors << err_msg
                    return nil
                end
                obj
            end

            def check_recipients
                if @to.count < 1 && @bcc_address.blank?
                    @errors << "No recipients"
                    return nil
                end
                @to.each do |recipient|
                    if check_type(recipient, Hash)
                        recipient[:email] = check_format(recipient[:email].to_s, EMAIL_FMT) || nil
                        if recipient[:email].blank?
                            @errors << "A recipient doesn't have an email address"
                        end

                        recipient[:name] = recipient[:name].to_s unless recipient[:name].blank?
                        recipient[:type] = recipient[:type].to_s unless recipient[:type].blank?
                    end
                end
            end

            def check_global_merge_vars
                @global_merge_vars.each { |var| check_type(var, Hash, :global_merge_var) }
            end

            def check_merge_vars
                @merge_vars.each do |var|
                    check_type(var, Hash, :merge_var)
                    if var[:rcpt].nil? || check_format(var[:rcpt].to_s, EMAIL_FMT, :merge_var_rcpt_email).nil?
                        @errors << "All non-global merge variables need a recipient email to apply to"
                    end
                    unless check_type(var[:vars], Array, :merge_var_rcpt_vars).nil?
                        var[:vars].each do |vvar|
                            check_type(vvar, Hash, :merge_var_rcpt_vars_var)
                        end
                    end
                end
            end

            def check_tags
                @tags.map! { |tag| check_format(tag.to_s, /^[^_]\w{1,49}$/, :tag) }
            end

            def check_google_analytics_domains
                @google_analytics_domains.map! { |domain| domain.to_s }
            end

            def check_metadata
                m = {}
                @metadata.each { |key, value| m[key.to_s] = value.to_s }
                @metadata = m
            end

            def check_recipient_metadata
                # TODO !
            end

            def check_attachments
                # TODO !
            end

            def check_images
                # TODO !
            end
        end
    end
end
