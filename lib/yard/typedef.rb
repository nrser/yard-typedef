# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'shellwords'

# Project / Package
# -----------------------------------------------------------------------

require_relative "./cli/typedef"
require_relative "./typedef/version"
require_relative "./typedef/html_helper"


# Namespace
# =======================================================================

module  YARD


# Definitions
# =======================================================================

module  Typedef

  # Constants
  # ============================================================================
  
  DEFAULT_DOMAIN = "docs.ruby-lang.org"
  
  DEFAULT_LANG = 'en'
  
  DEFAULT_HTTP_URLS = true
  
  # Available helper modules by their format (as found in `options.format`).
  # 
  # We only cover `:html` for the moment, but may add more in the future.
  # 
  # @return [Hash<Symbol, Module>]
  # 
  HELPERS_BY_FORMAT = {
    html: HtmlHelper,
  }.freeze


  # The {Proc} that we add to {YARD::Templates::Template.extra_includes} on
  # {.install!}. The proc accepts template options and responds with the helper
  # module corresponding to the format (if any - right now we only handle 
  # `:html`).
  # 
  # We want this to be a constant so we can tell if it's there and
  # avoid ever double-adding it.
  # 
  # @return [Proc<YARD::Templates::TemplateOptions -> Module?>]
  # 
  HELPER_FOR_OPTIONS = proc { |options|
    HELPERS_BY_FORMAT[ options.format ]
  }.freeze
  
  
  # Names of valid Ruby operator methods. Used to form 
  # {OPERATOR_METHOD_NAME_REGEXP_FRAGMENT}.
  # 
  # @return [::Array<::String>]
  # 
  OPERATOR_METHOD_NAMES = \
    (
      %w([] []= ** ~ ~ @+ @- * / % + - >> << & ^ |) +
      %w(<= < > >= <=> == === != =~ !~)
    ).map( &:freeze )
  
  
  # {Regexp} source fragment that matches a Ruby operator method name.
  # 
  # Used in {.normalize_name} to swap out '.' separators for '::' in operator
  # methods.
  # 
  # @return [::String]
  # 
  OPERATOR_METHOD_NAME_REGEXP_FRAGMENT = \
    OPERATOR_METHOD_NAMES.
      map { |op_name| "(?:#{ Regexp.escape op_name })" }
      .join '|'
  
  
  # Singleton Methods
  # ==========================================================================
  
  # @!group Configuration Singleton Methods
  # --------------------------------------------------------------------------
  
  # Configured to build `https://` URLs by default?
  # 
  # @example Default configuration responds with {DEFAULT_HTTP_URLS}
  #   YARD::Typedef.https_urls?
  #   #=> true
  # 
  # @return [Boolean]
  # 
  def self.https_urls?
    DEFAULT_HTTP_URLS
  end # .https_urls?
  
  
  # Configured domain used as the default to {.build_url}.
  # 
  # @example Default configuration responds with {DEFAULT_DOMAIN}
  #   YARD::Typedef.domain
  #   #=> 'docs.ruby-lang.org'
  # 
  # @return [String]
  # 
  def self.domain
    DEFAULT_DOMAIN
  end # .domain
  
  
  # Documentation language to {.build_url} for (when not overridden in method
  # call).
  # 
  # @example Default configuration responds with {DEFAULT_LANG}
  #   YARD::Typedef.lang
  #   #=> 'en'
  # 
  # @return [String]
  # 
  def self.lang
    DEFAULT_LANG
  end # .lang
  
  # @!endgroup Configuration Singleton Methods # *****************************
  
  
  # @!group Resolving Names Singleton Methods
  # --------------------------------------------------------------------------
  
  # Build a URL given a relative path to the document (see {.rel_path_for}).
  # 
  # Components may all be individually overridden via keyword arguments;
  # otherwise the current configuration values are used.
  # 
  # Format targets <docs.ruby-lang.org>, but *may* work for local or 
  # alternative versions as well.
  # 
  # @note
  #   Will **NOT** generate working URLs for <ruby-doc.org> because they
  #   divide language docs into "core" and "stdlib" using an unknown methodology
  #   (it's *probably* that C code is in "core" and Ruby in "stdlib", but I'm
  #   not sure, and not sure who would be).
  #
  # @example Using defaults
  #   YARD::Typedef.build_url 'String.html'
  #   #=> 'https://docs.ruby-lang.org/en/2.3.0/String.html'
  # 
  # @example Manually override components
  #   YARD::Typedef.build_url 'String.html',
  #     https: false,
  #     domain: 'example.com',
  #     lang: 'ja',
  #     version: '2.6.0'
  #   #=> 'http://example.com/ja/2.6.0/String.html'
  # 
  # @param [String] rel_path
  #   Relative path to the document, as returned from {.rel_path_for}.
  # 
  # @param [Boolean] https
  #   Build `https://` URLs (versus `http://`)? Defaults to {.https_urls?}.
  # 
  # @param [String] domain
  #   Domain docs are hosted at. Defaults to {.domain}.
  # 
  # @param [String] lang
  #   Language to link to, defaults to {.lang}.
  #   
  #   Note that at the time of writing (2019.03.08) only English ("en") and
  #   Japanese ("ja") are available on <docs.ruby-lang.org>.
  # 
  # @param [#to_s] version
  #   Ruby version for the URL. Anything that supports `#to_s` will work, but 
  #   meant for use with {String} or {Gem::Version} (the later of which being
  #   what {RubyVersion.minor} returns).
  #   
  #   Note that <docs.ruby-lang.org> uses only *minor* version-level resolution:
  #   you can link to `2.3.0` or `2.4.0`, but not `2.3.7`, `2.4.4`, etc.
  # 
  # @return [String]
  #   Fully-formed URL, ready for clicks!
  # 
  def self.build_url  rel_path,
                      https: self.https_urls?,
                      domain: self.domain,
                      lang: self.lang,
                      version: RubyVersion.minor
    File.join \
      "http#{ https ? 's' : '' }://",
      domain,
      lang,
      version.to_s,
      rel_path
  end
  
  # @!endgroup Resolving Names Singleton Methods # ***************************
  
  
  # @!group Querying Singleton Methods
  # --------------------------------------------------------------------------
  
  # Find names in the {ObjectMap.current} that match terms.
  # 
  # Terms are tested with `#===`, allowing use of {String}, {Regexp}, and 
  # potentially others.
  # 
  # `mode` controls if names must match any or all terms.
  # 
  # @param [Array<Object>] terms
  #   Objects that will be tested with `#===` against names in the map to select 
  #   results.
  # 
  # @return [Array<String>]
  #   Matching names.
  # 
  def self.grep *terms, mode: :any
    ObjectMap.
      current.
      names.
      select { |key|
        case mode
        when :any
          terms.any? { |term| term === key }
        when :all
          terms.all? { |term| term === key }
        else
          raise ArgumentError,
            "Bad mode, expected `:any` or `:all`, found #{ mode.inspect }"
        end
      }.
      sort_by( &:downcase )
  end # .grep
  
  # @!endgroup Querying Singleton Methods # **********************************
  
  
  # @!group Installation Singleton Methods
  # --------------------------------------------------------------------------

  # Add the {HELPER_FOR_OPTIONS} {Proc} to
  # {YARD::Templates::Template.extra_includes} (if it's not there already).
  # 
  # @see https://www.rubydoc.info/gems/yard/YARD/Templates/Template#extra_includes-class_method
  # 
  # @return [nil]
  # 
  def self.install!
    # NOTE  Due to YARD start-up order, this happens *before* log level is set,
    #       so the `--debug` CLI switch won't help see it... don't know a way to
    #       at the moment.
    log.debug "Installing `yard-typedef` plugin..."

    unless YARD::Templates::Template.extra_includes.include? HELPER_FOR_OPTIONS
      YARD::Templates::Template.extra_includes << HELPER_FOR_OPTIONS
    end

    YARD::CLI::CommandParser.commands[:stdlib] ||= YARD::CLI::Typedef

    nil
  end # .install!
  
  # @!endgroup Installation Singleton Methods # ******************************


  # General Utilities
  # ----------------------------------------------------------------------------
  
  # Normalize a stdlib name: remove "::" prefix if present, and convert "." to
  # "::".
  # 
  # @example Just passing through
  #   YARD::Typedef.normalize_name 'String#length'
  #   #=> 'String#length'
  # 
  # @example Strip "::" prefix
  #   YARD::Typedef.normalize_name '::String#length'
  #   #=> 'String#length'
  # 
  # @example Puke if it's not a {String}
  #   YARD::Typedef.normalize_name 123
  #   #=> raise TypeError, %(`name` must be a String, given Fixnum: 123)
  # 
  # @example Handle operator singleton methods separated by '.'
  #   YARD::Typedef.normalize_name 'Dir.[]'
  #   #=> 'Dir::[]'
  # 
  # @param [::String] name
  #   Code object name, as it may appear in YARD.
  # 
  # @return [::String]
  # 
  def self.normalize_name name
    unless name.is_a? ::String
      raise TypeError,
        "`name` must be a String, given #{ name.class }: #{ name.inspect }"
    end
    
    # Stdlib rdoc uses `ClassOrModule::class_method` format for class methods,
    # so we want to convert to that, and strip off any leading '::'
    name.
      # Strip off any leading '::'
      sub( /\A::/, '' ).
      # Convert most singleton methods using '.' to '::' (except operators)
      sub( /\.(\w+[\?\!]?)\z/, '::\1' ).
      # Convert operator singleton methods using '.' to '::'
      sub( /\.(#{ OPERATOR_METHOD_NAME_REGEXP_FRAGMENT })\z/, '::\1' )
  end # .normalize_name
  
  
  # Set the {.tmp_dir} where we put temporary files (like Ruby source 
  # downloads).
  # 
  # @param [Symbol | #to_s] value
  #   Either an object whose string representation expands to a path to an
  #   existing directory, or one of the following symbols:
  #   
  #   1.  `:system`, `:global` → `/tmp/yard-typedef`.
  #       
  #   2.  `:user` → `~/tmp/yard-typedef`.
  #       
  #   3.  `:gem`, `:install` → `tmp` relative to `yard-typedef`'s root
  #       directory ({YARD::Typedef::ROOT}).
  # 
  # @return [Pathname]
  #   The assigned path.
  # 
  def self.tmp_dir= value
    @tmp_dir = case value
    when :system, :global
      Pathname.new '/tmp/yard-typedef'
    when :user
      Pathname.new( '~/tmp/yard-typedef' ).expand_path
    when :gem, :install
      ROOT.join 'tmp'
    when :project
      Pathname.getwd.join 'tmp', 'yard-typedef'
    else
      dir = Pathname.new( value.to_s ).expand_path

      unless dir.directory?
        raise ArgumentError,
          "When assigning a custom tmp_dir path it must be an existing " +
          "directory, received #{ value.to_s.inspect }"
      end
    end

    FileUtils.mkdir_p @tmp_dir unless @tmp_dir.exist?

    @tmp_dir
  end


  # Get where to put temporary shit, most Ruby source code that's been downloaded
  # to generate the link maps from.
  # 
  # @return [Pathname]
  # 
  def self.tmp_dir &block
    if @tmp_dir.nil?
      self.tmp_dir = repo? ? :gem : :user
    end

    if block
      Dir.chdir @tmp_dir, &block
    else
      @tmp_dir
    end
  end


  # Run a {Kernel#system}, raising if it fails.
  # 
  # @param [Array] args
  #   See {Kernel#system}.
  # 
  # @return [true]
  # 
  # @raise [SystemCallError]
  #   If the command fails.
  # 
  def self.system! *args
    opts  = args[-1].is_a?( Hash )  ? args.pop : {}
    env   = args[0].is_a?( Hash )   ? args.shift : {}

    log.info [
      "Making system call:",
      "\t#{ Shellwords.join args }",
      ( opts.empty? ? nil : "\toptions: #{ opts.inspect }" ),
      ( env.empty? ? nil : "\tenv: #{ env.inspect }" ),
    ].compact.join( "\n" )

    Kernel.system( *args ).tap { |success|
      unless success
        raise SystemCallError.new \
          %{ Code #{ $?.exitstatus } error executing #{ args.inspect } },
          $?.exitstatus
      end
    }
  end


  # Make a `GET` request. Follows redirects. Handles SSL.
  # 
  # @param [String] url
  #   What ya want.
  # 
  # @param [Integer] redirect_limit
  #   Max number of redirects to follow before it gives up.
  # 
  # @return [Net::HTTPResponse]
  #   The first successful response that's not a redirect.
  # 
  # @raise [Net::HTTPError]
  #   If there was an HTTP error.
  # 
  # @raise 
  # 
  def self.http_get url, redirect_limit = 5
    raise "Too many HTTP redirects" if redirect_limit < 0

    uri = URI url
    request = Net::HTTP::Get.new uri.path
    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https',
    ) { |http| http.request request }
    
    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      http_get response['location'], redirect_limit - 1
    else
      response.error!
    end 
  end
  
  
  # Dump a hash of values as a `debug`-level log message (`log` is a global
  # function when you're hangin' in the YARD).
  # 
  # @example Dump values with a message
  #   obj = [ 1, 2, 3 ]
  #   
  #   dump "There was a problem with the ", obj, "object!",
  #     value_a: 'aye!',
  #     value_b: 'bzzz'
  # 
  # @example Dump values without a message
  #   dump value_a: 'aye!', value_b: 'bzzz'
  # 
  # @param [Array<String | Object>] message
  #   Optional log message. Entries will be space-joined to form the message 
  #   string: strings will be left as-is, and other objects will be
  #   stringified by calling their `#inspect` method. See examples.
  # 
  # @param [Hash<Symbol, Object>] values
  #   Map of names to values to dump.
  # 
  # @return
  #   Whatever `log.debug` returns.
  # 
  def self.dump *message, **values

    max_name_length = values.
      keys.
      map { |name| name.to_s.length }.
      max

    values_str = values.
      map { |name, value|
        name_str = "%-#{ max_name_length + 2 }s" % "#{ name }:"

        "  #{ name_str } #{ value.inspect } (#{ value.class })"
      }.
      join( "\n" )
    
    message_str = message.
      map { |part|
        case part
        when String
          part
        else
          part.inspect
        end
      }.
      join( " " )
    
    log_str = "Values:\n\n#{ values_str }\n"
    log_str = "#{ message_str }\n\n#{ log_str }" unless message_str.empty?

    log.debug "yard-typedef: #{ log_str }"
  end # .dump
  
end # module Typedef


# /Namespace
# =======================================================================

end # module YARD
