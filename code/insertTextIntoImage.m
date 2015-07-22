function imageWithText = insertTextIntoImage(image, textString, position, fontSize)

    f = figure('Visible', 'off');
    imshow(image);
    text('Position', position, 'String', textString, 'FontSize', fontSize);

    fFrame = getframe(gca);
    imageWithText = fFrame.cdata;

    close(f);

    imageWithText = imageWithText(1 : size(image, 1), 1 : size(image, 2), 1 : size(image, 3));

end