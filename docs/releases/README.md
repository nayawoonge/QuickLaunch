# Publishing a release / 릴리스 작성 가이드

Keep a short user-facing summary in `README.md` and `README.ko.md`. Store the full release description in `docs/releases/vX.Y.Z.md`, with English first and Korean below. The release workflow uses that file as the GitHub Release body and attaches the built `QuickLaunch.dmg`.

README에는 사용자에게 필요한 변경점을 짧게 요약하고, 자세한 설명은 `docs/releases/vX.Y.Z.md`에 영문·한국어로 작성합니다. 워크플로우가 이 파일을 GitHub Release 본문으로 사용하고, 빌드한 `QuickLaunch.dmg`를 첨부합니다.

## Prepare and publish / 준비와 배포

1. Pick an unused stable version tag such as `v1.0.3`. Set `CFBundleShortVersionString` in `Support/Info.plist` to `1.0.3` and increase `CFBundleVersion`.
2. Write `docs/releases/v1.0.3.md`: what changed, how users enable it, and any relevant limitations. Include only changes since the previous release. Update the summaries in both READMEs.
3. Review and commit the app changes, notes, workflow, and version together. Create the tag on that commit and push the branch and tag together.
4. Check the **Release** workflow in GitHub Actions. A successful run publishes the DMG and the release description. `main` alone does not trigger a release.

1. 아직 사용하지 않은 버전(예: `v1.0.3`)을 정하고, `Support/Info.plist`의 앱 버전을 `1.0.3`으로 수정하며 빌드 번호도 올립니다.
2. `docs/releases/v1.0.3.md`에 이전 버전 이후의 변경점, 사용 방법, 관련 제한 사항을 적고 영문·한국어 README 요약도 갱신합니다.
3. 앱 수정·릴리스 노트·워크플로우·버전을 함께 검토하고 커밋합니다. 해당 커밋에 새 태그를 붙이고 브랜치와 태그를 같이 푸시합니다.
4. GitHub Actions의 **Release**가 성공하면 DMG와 변경 설명이 게시됩니다. `main`만 푸시하면 릴리스는 생성되지 않습니다.

The workflow checks that the tag, app version, and notes file match. It builds a universal DMG for Apple Silicon and Intel. For a manual workflow run, enter an existing tag in the **tag** input; the workflow checks out that exact tag.

워크플로우는 태그·앱 버전·노트 파일이 일치하는지 확인하고 Apple Silicon·Intel용 유니버설 DMG를 빌드합니다. Actions에서 수동 실행할 때는 **tag** 입력란에 기존 태그를 적으세요. 지정한 태그의 소스로 빌드합니다.

## Edit the description on GitHub / GitHub에서 설명 수정

Open **Releases → the release → Edit (pencil)**, edit the description, and choose **Update release**. When creating a release manually, paste the notes into **Describe this release**, attach the matching DMG in the assets area, and publish. Changes belong in the Release body; they are not a separate description field on the DMG asset. See [GitHub's release guide](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

**Releases → 해당 버전 → Edit(연필)**에서 설명을 수정하고 **Update release**를 누릅니다. 직접 새 릴리스를 만들 경우 **Describe this release**에 노트 내용을 붙여 넣고, 첨부 영역에 해당 버전의 DMG를 올려 게시합니다. 변경 설명은 DMG 파일별 설명란이 아니라 Release 본문에 작성합니다.

Keep source notes in sync when you edit the published description. Rerunning the original tag uses the notes saved in that tag, not later changes on `main`.

게시한 설명을 수정하면 저장소의 노트도 함께 갱신하세요. 원래 태그로 워크플로우를 다시 실행하면 이후 `main`의 수정이 아니라 그 태그에 저장된 노트가 사용됩니다.
