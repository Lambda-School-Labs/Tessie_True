import cv2
import pytesseract
from skimage.filters import threshold_sauvola


def preprocessing(image):
    """
    `Threshold Sauvola` imaging function:

    T = m(x,y) * (1 + k * ((s(x,y) / R) - 1))
    where m(x,y) and s(x,y) are the mean and standard deviation of
    pixel (x,y) local neighborhood defined by a rectangular window with
    size 25 times 25 centered around the pixel. k is a configurable
    parameter that weights the effect of standard deviation. R is
    the maximum standard deviation of a grayscale image.

    Processes image using methods explained above.
    Args:
        image: file
            Image file to be preprocessed.
    Returns:
        binary_sauvola: Image
            Black and white image used for transcription.

    """
    # Read in submission image
    img = cv2.imread(image, 0)

    # Dynamic range of standard deviation around a window of pixels
    window_size = 25  # (a window of 25 pixels)
    thresh_sauvola = threshold_sauvola(img, window_size=window_size)
    binary_sauvola = img > thresh_sauvola

    # Return processed image
    return binary_sauvola


def transcribe(image, lang="eng"):
    """
    Transcribes image file to a string using pytesseract.
    Args:
        image: file
            Image file that is desired to be described.
        lang: str
            Base language used to for image transcription. Defaults to English
            if no language is provided.
    Returns:
        str
            String containing Tesseract's transcription using the provided
            language file.
    """
    # Process submission image
    processed = preprocessing(image)

    # Return transcription
    return pytesseract.image_to_string(processed, lang=lang)
