<?php
ini_set('display_errors', 1);
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header("Access-Control-Allow-Headers: X-Requested-With");

if (isset($_POST['image']) && isset($_POST['sequence'])) {
    $base64_code = $_POST['image'];
    $data = explode(',', $base64_code);
    $fp = fopen("./images/" . $_POST['sequence'] . ".png", "w+");
    fwrite($fp, base64_decode($data[1]));
    fclose($fp);

    $descriptionObject->name = "Sequence " . $_POST['sequence'] . " by 0xJitzu";
    $descriptionObject->description = "Sequence " . $_POST['sequence'] . " is a generative audio created with LayeredMusic, a project by NFT-Studio. Original audio tracks created by 0xJitzu. Listen the track here: https://layeredmusic.nftstud.io/#/play/".$_POST['sequence'];
    $descriptionObject->image = "https://layeredmusic.nftstud.io/api/images/" . $_POST['sequence'] . ".png";
    $descriptionObject->external_url = "https://layeredmusic.nftstud.io/#/play/".$_POST['sequence'];

    $fp = fopen("./" . $_POST['sequence'], "w+");
    fwrite($fp, json_encode($descriptionObject));
    fclose($fp);

    echo "GENERATED";
}
