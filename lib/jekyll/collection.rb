module Jekyll
  class Collection
    attr_reader :site, :label

    # Create a new Collection.
    #
    # site - the site to which this collection belongs.
    # label - the name of the collection
    #
    # Returns nothing.
    def initialize(site, label)
      @site  = site
      @label = sanitize_label(label)
    end

    # Fetch the Documents in this collection.
    # Defaults to an empty array if no documents have been read in.
    #
    # Returns an array of Jekyll::Document objects.
    def docs
      @docs ||= []
    end

    # Read the allowed documents into the collection's array of docs.
    #
    # Returns the sorted array of docs.
    def read
      filtered_entries.each do |file_path|
        doc = Jekyll::Document.new(Jekyll.sanitized_path(directory, file_path), { site: site, collection: self })
        doc.read
        docs << doc
      end
      docs.sort!
    end

    # All the entries in this collection.
    #
    # Returns an Array of file paths to the documents in this collection
    #   relative to the collection's directory
    def entries
      return Array.new unless exists?
      Dir.glob(File.join(directory, "**", "*.*")).map do |entry|
        entry[File.join(directory, "")] = ''; entry
      end
    end

    # Filtered version of the entries in this collection.
    # See `Jekyll::EntryFilter#filter` for more information.
    #
    # Returns a list of filtered entry paths.
    def filtered_entries
      return Array.new unless exists?
      Dir.chdir(directory) do
        entry_filter.filter(entries)
      end
    end

    # The directory for this Collection, relative to the site source.
    #
    # Returns a String containing the directory name where the collection
    #   is stored on the filesystem.
    def relative_directory
      "_#{label}"
    end

    # The full path to the directory containing the
    #
    # Returns a String containing th directory name where the collection
    #   is stored on the filesystem.
    def directory
      Jekyll.sanitized_path(site.source, relative_directory)
    end

    # Checks whether the directory "exists" for this collection.
    # The directory must exist on the filesystem and must not be a symlink
    #   if in safe mode.
    #
    # Returns false if the directory doesn't exist or if it's a symlink
    #   and we're in safe mode.
    def exists?
      File.directory?(directory) && !(File.symlink?(directory) && site.safe)
    end

    # The entry filter for this collection.
    # Creates an instance of Jekyll::EntryFilter.
    #
    # Returns the instance of Jekyll::EntryFilter for this collection.
    def entry_filter
      @entry_filter ||= Jekyll::EntryFilter.new(site, relative_directory)
    end

    # An inspect string.
    #
    # Returns the inspect string
    def inspect
      "#<Jekyll::Collection @label=#{label} docs=#{docs}>"
    end

    # Produce a sanitized label name
    # Label names may not contain anything but alphanumeric characters,
    #   underscores, and hyphens.
    #
    # label - the possibly-unsafe label
    #
    # Returns a sanitized version of the label.
    def sanitize_label(label)
      label.gsub(/[^a-z0-9_\-]/i, '')
    end

    # Produce a representation of this Collection for use in Liquid.
    # Exposes two attributes:
    #   - label
    #   - docs
    #
    # Returns a representation of this collection for use in Liquid.
    def to_liquid
      docs
    end

  end
end
