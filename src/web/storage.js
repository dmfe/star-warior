mergeInto(LibraryManager.library, {
    star_warior_load_max_score: function(output, capacity) {
        try {
            const value = localStorage.getItem(
                "star-warior.max-score.v1"
            );

            if (value === null) {
                return 0;
            }

            const required = lengthBytesUTF8(value);

            if (required + 1 > capacity) {
                return -1;
            }

            stringToUTF8(value, output, capacity);
            return required;
        } catch (error) {
            console.error("Failed to load max score: ", error);
            return -1;
        }
    },

    star_warior_save_max_score: function(value, length) {
        try {
            const text = UTF8ToString(value, length);

            localStorage.setItem(
                "star-warior.max-score.v1",
                text
            );

            return 0;
        } catch (error) {
            console.error("Failed to save max score: ", error);
            return -1;
        }
    },
});
